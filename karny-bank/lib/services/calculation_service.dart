// lib/services/calculation_service.dart
// Financial calculations for Karny Bank
// Handles interest, bonus, and allowance calculations with proper precision

import 'database_models.dart';

class CalculationService {
  /// Calculate weekly allowance amount in agorot
  /// Allowance equals the child's current age
  static int calculateWeeklyAllowance(Account account) {
    final age = account.getAge();
    // Age in ILS, convert to agorot (multiply by 100)
    return age * 100;
  }

  /// Calculate annual interest in agorot
  /// Interest = balance * rate / 100
  /// Uses integer arithmetic to avoid floating point errors
  ///
  /// Example: balance = 10000 agorot (100 ILS), rate = 280 (2.8%)
  /// interest = (10000 * 280) / 10000 = 280 agorot (2.80 ILS)
  static int calculateAnnualInterest(
    int balanceAgorot,
    int annualRateInTenthsOfPercent,
  ) {
    // annualRateInTenthsOfPercent is stored as 280 for 2.8%
    // Formula: balance * rate / 10000 (since rate is 0.01% per unit)
    return (balanceAgorot * annualRateInTenthsOfPercent) ~/ 10000;
  }

  /// Calculate quarterly bonus in agorot
  /// Bonus = balance * rate / 100, only if NO withdrawals in quarter
  /// Bonus rate stored as 120 for 1.2%
  static int calculateQuarterlyBonus(
    int balanceAgorot,
    int bonusRateInTenthsOfPercent,
  ) {
    // bonusRateInTenthsOfPercent is stored as 120 for 1.2%
    // Formula: balance * rate / 10000
    return (balanceAgorot * bonusRateInTenthsOfPercent) ~/ 10000;
  }

  /// Calculate compound interest over multiple years
  /// Useful for estimates and backtesting
  static int calculateCompoundInterest(
    int principalAgorot,
    int annualRateInTenthsOfPercent,
    int years,
  ) {
    int balance = principalAgorot;
    for (int i = 0; i < years; i++) {
      final interest = calculateAnnualInterest(balance, annualRateInTenthsOfPercent);
      balance += interest;
    }
    return balance;
  }

  /// Get the quarter (1-4) for a given date
  static int getQuarter(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }

  /// Get the end date of a quarter
  static DateTime getQuarterEndDate(int year, int quarter) {
    switch (quarter) {
      case 1:
        return DateTime(year, 3, 31);
      case 2:
        return DateTime(year, 6, 30);
      case 3:
        return DateTime(year, 9, 30);
      case 4:
        return DateTime(year, 12, 31);
      default:
        throw ArgumentError('Quarter must be 1-4');
    }
  }

  /// Get the start date of a quarter
  static DateTime getQuarterStartDate(int year, int quarter) {
    switch (quarter) {
      case 1:
        return DateTime(year, 1, 1);
      case 2:
        return DateTime(year, 4, 1);
      case 3:
        return DateTime(year, 7, 1);
      case 4:
        return DateTime(year, 10, 1);
      default:
        throw ArgumentError('Quarter must be 1-4');
    }
  }

  /// Get which quarter contains a given date
  static (int year, int quarter) getQuarterForDate(DateTime date) {
    final quarter = getQuarter(date);
    return (date.year, quarter);
  }

  /// Determine the day of the week (ISO 8601: 0=Sunday, 1=Monday, etc.)
  /// Note: Dart's DateTime.weekday returns 1=Monday, 7=Sunday
  /// This converts to ISO standard (0=Sunday, 1=Monday, etc.)
  static int getDayOfWeekIso8601(DateTime date) {
    final dartWeekday = date.weekday; // 1=Monday, 7=Sunday
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  /// Check if a given date is the specified day of the week
  static bool isDateOnDayOfWeek(DateTime date, int dayOfWeek) {
    // dayOfWeek: 0=Sunday, 1=Monday, etc.
    final isoDay = getDayOfWeekIso8601(date);
    return isoDay == dayOfWeek;
  }

  /// Get the next occurrence of a specific day of the week from a given date
  static DateTime getNextOccurrenceOfDayOfWeek(DateTime from, int dayOfWeek) {
    // dayOfWeek: 0=Sunday, 1=Monday, etc.
    DateTime current = from;

    while (!isDateOnDayOfWeek(current, dayOfWeek)) {
      current = current.add(const Duration(days: 1));
    }

    return current;
  }

  /// Format agorot as ILS string for display
  static String formatAgorotAsILS(int agorot) {
    final ils = agorot / 100;
    return '₪${ils.toStringAsFixed(2)}';
  }

  /// Parse ILS string to agorot
  /// Example: "14.50" ILS -> 1450 agorot
  static int parseILSToAgorot(String ilsString) {
    final double ils = double.parse(ilsString);
    return (ils * 100).toInt();
  }

  /// Calculate percentage of balance
  /// Example: percentageOfBalance(1000, 10) returns 100 (10% of 1000)
  static int percentageOfBalance(int balanceAgorot, int percentage) {
    return (balanceAgorot * percentage) ~/ 100;
  }

  /// Round agorot to nearest shekel (100 agorot)
  static int roundToNearestShekel(int agorot) {
    return ((agorot + 50) ~/ 100) * 100;
  }

  /// Determine if birthday affects weekly allowance
  /// Returns true if today is a birthday and today is the allowance day
  static bool isBirthdayAllowanceDay(
    Account account,
    int configuredAllowanceDay,
  ) {
    if (!account.isBirthdayToday()) return false;

    final today = DateTime.now();
    return isDateOnDayOfWeek(today, configuredAllowanceDay);
  }

  /// Estimate future balance after N days of saving
  /// Useful for goal tracking
  static int estimateFutureBalance(
    int currentBalance,
    int weeklyAllowanceAmount,
    int daysInFuture,
  ) {
    // Simplified: assumes consistent weekly deposits, no interest/bonus
    final weeksInFuture = daysInFuture ~/ 7;
    return currentBalance + (weeklyAllowanceAmount * weeksInFuture);
  }

  /// Calculate how many days until next deposit (weekly allowance)
  static int daysUntilNextAllowance(int configuredAllowanceDay) {
    final now = DateTime.now();
    final today = getDayOfWeekIso8601(now);

    int daysUntil = (configuredAllowanceDay - today) % 7;
    if (daysUntil == 0 && now.hour > 0) {
      // If today is allowance day but past midnight, it's for next week
      daysUntil = 7;
    }
    return daysUntil;
  }

  /// Validate transaction amount
  static bool isValidTransactionAmount(int amountAgorot) {
    return amountAgorot > 0 && amountAgorot < 10000000; // Max ~100,000 ILS
  }

  /// Calculate total deposits in a date range
  static int calculateTotalDeposits(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isDeposit())
        .fold<int>(0, (sum, t) => sum + t.amountAgorot);
  }

  /// Calculate total withdrawals in a date range
  static int calculateTotalWithdrawals(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isWithdrawal())
        .fold<int>(0, (sum, t) => sum + t.amountAgorot);
  }

  /// Calculate net change in date range
  static int calculateNetChange(List<Transaction> transactions) {
    return calculateTotalDeposits(transactions) -
        calculateTotalWithdrawals(transactions);
  }

  /// Get transaction statistics for a date range
  static TransactionStatistics getTransactionStatistics(
    List<Transaction> transactions,
  ) {
    final deposits = transactions.where((t) => t.isDeposit()).toList();
    final withdrawals = transactions.where((t) => t.isWithdrawal()).toList();

    final totalDeposits = calculateTotalDeposits(transactions);
    final totalWithdrawals = calculateTotalWithdrawals(transactions);

    return TransactionStatistics(
      totalTransactions: transactions.length,
      totalDeposits: totalDeposits,
      totalWithdrawals: totalWithdrawals,
      netChange: totalDeposits - totalWithdrawals,
      depositCount: deposits.length,
      withdrawalCount: withdrawals.length,
      averageDeposit:
          deposits.isEmpty ? 0 : totalDeposits ~/ deposits.length,
      averageWithdrawal: withdrawals.isEmpty ? 0 : totalWithdrawals ~/ withdrawals.length,
      maxDeposit: deposits.isEmpty
          ? 0
          : deposits
              .map((t) => t.amountAgorot)
              .reduce((a, b) => a > b ? a : b),
      maxWithdrawal: withdrawals.isEmpty
          ? 0
          : withdrawals
              .map((t) => t.amountAgorot)
              .reduce((a, b) => a > b ? a : b),
    );
  }
}

/// Statistics about transactions in a date range
class TransactionStatistics {
  final int totalTransactions;
  final int totalDeposits;
  final int totalWithdrawals;
  final int netChange;
  final int depositCount;
  final int withdrawalCount;
  final int averageDeposit;
  final int averageWithdrawal;
  final int maxDeposit;
  final int maxWithdrawal;

  TransactionStatistics({
    required this.totalTransactions,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.netChange,
    required this.depositCount,
    required this.withdrawalCount,
    required this.averageDeposit,
    required this.averageWithdrawal,
    required this.maxDeposit,
    required this.maxWithdrawal,
  });

  @override
  String toString() => '''
TransactionStatistics(
  Total Transactions: $totalTransactions,
  Deposits: $depositCount (total: ${CalculationService.formatAgorotAsILS(totalDeposits)}),
  Withdrawals: $withdrawalCount (total: ${CalculationService.formatAgorotAsILS(totalWithdrawals)}),
  Net Change: ${CalculationService.formatAgorotAsILS(netChange)},
  Avg Deposit: ${CalculationService.formatAgorotAsILS(averageDeposit)},
  Avg Withdrawal: ${CalculationService.formatAgorotAsILS(averageWithdrawal)},
  Max Deposit: ${CalculationService.formatAgorotAsILS(maxDeposit)},
  Max Withdrawal: ${CalculationService.formatAgorotAsILS(maxWithdrawal)}
)
  ''';
}
