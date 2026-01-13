// lib/services/transaction_service.dart
// High-level transaction management combining database and calculations
// Provides business logic for deposits, withdrawals, and queries

import 'database_service.dart';
import 'calculation_service.dart';
import 'database_models.dart';

class TransactionService {
  /// Process a manual deposit (parent adds money)
  static Future<int> addManualDeposit({
    required int accountId,
    required int amountAgorot,
    String? notes,
  }) async {
    if (!CalculationService.isValidTransactionAmount(amountAgorot)) {
      throw ArgumentError('Invalid transaction amount: $amountAgorot');
    }

    final account = await DatabaseService.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    final newBalance = account.currentBalanceAgorot + amountAgorot;

    return await DatabaseService.addTransaction(
      accountId: accountId,
      type: TransactionType.manualDeposit,
      amountAgorot: amountAgorot,
      postedDate: DateTime.now(),
      balanceAfter: newBalance,
      notes: notes ?? 'Manual deposit by parent',
      isManual: true,
    );
  }

  /// Process a manual withdrawal (child spends money)
  /// Validates sufficient funds
  static Future<int> addManualWithdrawal({
    required int accountId,
    required int amountAgorot,
    String? notes,
  }) async {
    if (!CalculationService.isValidTransactionAmount(amountAgorot)) {
      throw ArgumentError('Invalid transaction amount: $amountAgorot');
    }

    final account = await DatabaseService.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (amountAgorot > account.currentBalanceAgorot) {
      throw Exception(
        'Insufficient funds. Trying to withdraw ${CalculationService.formatAgorotAsILS(amountAgorot)} '
        'but balance is ${CalculationService.formatAgorotAsILS(account.currentBalanceAgorot)}',
      );
    }

    final newBalance = account.currentBalanceAgorot - amountAgorot;

    return await DatabaseService.addTransaction(
      accountId: accountId,
      type: TransactionType.manualWithdrawal,
      amountAgorot: amountAgorot,
      postedDate: DateTime.now(),
      balanceAfter: newBalance,
      notes: notes ?? 'Manual withdrawal by child',
      isManual: true,
    );
  }

  /// Get transaction history for an account with filters
  static Future<List<Transaction>> getAccountHistory({
    required int accountId,
    TransactionType? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
  }) async {
    return await DatabaseService.getTransactions(
      accountId: accountId,
      type: typeFilter,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Get all transactions across all accounts with optional filtering
  static Future<List<Transaction>> getAllTransactions({
    TransactionType? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final accounts = await DatabaseService.getAllAccounts();
    final allTransactions = <Transaction>[];

    for (final account in accounts) {
      final transactions = await DatabaseService.getTransactions(
        accountId: account.id,
        type: typeFilter,
        startDate: startDate,
        endDate: endDate,
      );
      allTransactions.addAll(transactions);
    }

    // Sort by date descending
    allTransactions.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return allTransactions;
  }

  /// Get recent transactions for dashboard display
  static Future<Map<String, List<Transaction>>> getRecentTransactionsByAccount(
      {int limitPerAccount = 10}) async {
    final result = <String, List<Transaction>>{};
    final accounts = await DatabaseService.getAllAccounts();

    for (final account in accounts) {
      final transactions = await DatabaseService.getTransactions(
        accountId: account.id,
        limit: limitPerAccount,
      );
      result[account.name] = transactions;
    }

    return result;
  }

  /// Get deposit transactions only
  static Future<List<Transaction>> getDeposits({
    int? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allDeposits = <Transaction>[];

    // Get all deposit types
    for (final type in [
      TransactionType.manualDeposit,
      TransactionType.allowance,
      TransactionType.interest,
      TransactionType.bonus,
    ]) {
      final transactions = await DatabaseService.getTransactions(
        accountId: accountId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      allDeposits.addAll(transactions);
    }

    allDeposits.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return allDeposits;
  }

  /// Get withdrawal transactions only
  static Future<List<Transaction>> getWithdrawals({
    int? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await DatabaseService.getTransactions(
      accountId: accountId,
      type: TransactionType.manualWithdrawal,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get statistics for an account
  static Future<AccountStatistics> getAccountStatistics({
    required int accountId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final account = await DatabaseService.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    final transactions = await DatabaseService.getTransactions(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );

    final stats = CalculationService.getTransactionStatistics(transactions);

    return AccountStatistics(
      accountName: account.name,
      periodStart: startDate,
      periodEnd: endDate,
      statistics: stats,
    );
  }

  /// Get all transactions of a specific type
  static Future<List<Transaction>> getTransactionsByType(
    TransactionType type, {
    int? accountId,
  }) async {
    return await DatabaseService.getTransactions(
      accountId: accountId,
      type: type,
    );
  }

  /// Check if withdrawal is possible
  static Future<bool> canWithdraw(int accountId, int amountAgorot) async {
    final account = await DatabaseService.getAccountById(accountId);
    if (account == null) return false;
    return amountAgorot <= account.currentBalanceAgorot;
  }

  /// Get withdrawal suggestion when insufficient funds
  static String getInsufficientFundsMessage(
    Account account,
    int requestedAmount,
  ) {
    final shortfall = requestedAmount - account.currentBalanceAgorot;
    final shortfallIls =
        CalculationService.formatAgorotAsILS(shortfall);
    final balanceIls =
        CalculationService.formatAgorotAsILS(account.currentBalanceAgorot);
    final requestedIls =
        CalculationService.formatAgorotAsILS(requestedAmount);

    return '''
Insufficient funds!

Requested: $requestedIls
Current Balance: $balanceIls
Shortfall: $shortfallIls

Would you like to:
1. Reduce the withdrawal amount to $balanceIls?
2. Set a goal to save for this item?
3. Cancel
    ''';
  }

  /// Reverse a withdrawal (parent cancels a withdrawal for child)
  /// Creates a new deposit transaction for the reversal
  static Future<int> reverseWithdrawal({
    required int withdrawalTransactionId,
    String? reason,
  }) async {
    final original =
        await DatabaseService.getTransactionById(withdrawalTransactionId);
    if (original == null) {
      throw Exception('Transaction not found');
    }

    if (original.type != TransactionType.manualWithdrawal) {
      throw Exception('Only withdrawals can be reversed');
    }

    // Create a deposit to reverse the withdrawal
    return await addManualDeposit(
      accountId: original.accountId,
      amountAgorot: original.amountAgorot,
      notes:
          'Reversal of withdrawal from ${original.postedDate}${reason != null ? ': $reason' : ''}',
    );
  }

  /// Get next occurrence of weekly allowance
  static Future<String> getNextAllowanceInfo() async {
    final config = await DatabaseService.getConfiguration();
    final daysUntil =
        CalculationService.daysUntilNextAllowance(config.weeklyAllowanceDay);
    final dayName = config.getAllowanceDayName();

    if (daysUntil == 0) {
      return 'Allowance is deposited today ($dayName)!';
    } else if (daysUntil == 1) {
      return 'Allowance deposits tomorrow ($dayName)';
    } else {
      return 'Next allowance: $dayName (in $daysUntil days)';
    }
  }

  /// Get next bonus dates
  static Future<List<String>> getNextBonusDates() async {
    final now = DateTime.now();
    final dates = <String>[];

    for (int q = 1; q <= 4; q++) {
      final endDate =
          CalculationService.getQuarterEndDate(now.year, q);
      if (endDate.isAfter(now)) {
        final daysLeft = endDate.difference(now).inDays;
        final month = endDate.month;
        final day = endDate.day;
        dates.add('Q$q: $month/$day (in $daysLeft days)');
      }
    }

    // If no future quarters this year, show next year's Q1
    if (dates.isEmpty) {
      final nextYear = now.year + 1;
      final date = DateTime(nextYear, 3, 31);
      dates.add('Q1 $nextYear: 3/31');
    }

    return dates;
  }

  /// Estimate balance after next allowance
  static Future<int> estimateBalanceAfterNextAllowance(
    Account account,
  ) async {
    final config = await DatabaseService.getConfiguration();
    final daysUntil =
        CalculationService.daysUntilNextAllowance(config.weeklyAllowanceDay);
    final allowance =
        CalculationService.calculateWeeklyAllowance(account);

    // Add some deposits that might happen in the meantime
    return account.currentBalanceAgorot +
        allowance +
        CalculationService.estimateFutureBalance(
          0,
          allowance,
          daysUntil,
        );
  }

  /// Export transaction history as CSV (useful for reports)
  static Future<String> exportTransactionsAsCSV({
    int? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await DatabaseService.getTransactions(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      limit: 10000,
    );

    final csv = StringBuffer();
    csv.writeln('Date,Time,Account Owner,Type,Amount (ILS),New Balance (ILS),Notes');

    for (final txn in transactions) {
      final account = await DatabaseService.getAccountById(txn.accountId);
      csv.writeln(
        '${txn.postedDate.toIso8601String().split('T')[0]}'
        ',${txn.transactionDatetime.toIso8601String().split('T')[1]}'
        ',${account?.name ?? 'Unknown'}'
        ',${txn.type.displayName()}'
        ',${CalculationService.formatAgorotAsILS(txn.amountAgorot).replaceAll('₪', '')}'
        ',${CalculationService.formatAgorotAsILS(txn.balanceAfter).replaceAll('₪', '')}'
        ,'${txn.notes ?? ''}'
      );
    }

    return csv.toString();
  }
}

/// Statistics for an account over a period
class AccountStatistics {
  final String accountName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final TransactionStatistics statistics;

  AccountStatistics({
    required this.accountName,
    required this.periodStart,
    required this.periodEnd,
    required this.statistics,
  });

  @override
  String toString() => '''
$accountName Statistics (${periodStart.toIso8601String().split('T')[0]} to ${periodEnd.toIso8601String().split('T')[0]}):
${statistics.toString()}
  ''';
}
