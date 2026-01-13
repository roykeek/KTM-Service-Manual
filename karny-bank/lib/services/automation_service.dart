// lib/services/automation_service.dart
// Automated transaction triggers for Karny Bank
// Handles weekly allowances, quarterly bonuses, and annual interest

import 'database_service.dart';
import 'calculation_service.dart';
import 'database_models.dart';

class AutomationService {
  /// Run all automation checks on app startup
  /// This should be called once when the app initializes
  static Future<AutomationResult> runAllAutomationChecks() async {
    final result = AutomationResult();

    try {
      // Run in order of typical occurrence
      result.allowanceResult = await processWeeklyAllowances();
      result.interestResult = await processAnnualInterest();
      result.bonusResults = {
        1: await processQuarterlyBonus(1),
        2: await processQuarterlyBonus(2),
        3: await processQuarterlyBonus(3),
        4: await processQuarterlyBonus(4),
      };

      result.success = true;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  // ============================================================================
  // WEEKLY ALLOWANCE
  // ============================================================================

  /// Process weekly allowance deposits for all accounts
  /// Called on app startup to check if allowance should be deposited today
  static Future<AllowanceResult> processWeeklyAllowances() async {
    final result = AllowanceResult();
    final config = await DatabaseService.getConfiguration();

    // Check if today is the configured allowance day
    final now = DateTime.now();
    final isAllowanceDay = CalculationService.isDateOnDayOfWeek(
      now,
      config.weeklyAllowanceDay,
    );

    if (!isAllowanceDay) {
      result.processed = false;
      result.message = 'Today is not the configured allowance day';
      return result;
    }

    // Check if already processed today
    final lastCheck =
        await DatabaseService.getAppStateLastExecuted('last_allowance_check');
    if (lastCheck != null && lastCheck.year == now.year && lastCheck.month == now.month && lastCheck.day == now.day) {
      result.processed = false;
      result.message = 'Allowance already processed today';
      return result;
    }

    // Process allowance for each account
    final accounts = await DatabaseService.getAllAccounts();
    for (final account in accounts) {
      try {
        // Calculate allowance amount
        int allowanceAmount =
            CalculationService.calculateWeeklyAllowance(account);

        // If today is also their birthday, no extra allowance
        // (Birthday doesn't change age on this day, only next day)

        // Create deposit transaction
        final currentBalance = account.currentBalanceAgorot;
        final newBalance = currentBalance + allowanceAmount;

        await DatabaseService.addTransaction(
          accountId: account.id,
          type: TransactionType.allowance,
          amountAgorot: allowanceAmount,
          postedDate: now,
          balanceAfter: newBalance,
          notes: 'Weekly allowance - Age ${account.getAge()}',
          isManual: false,
        );

        result.processedAccounts.add(
          ProcessedAccountRecord(
            accountName: account.name,
            amountAgorot: allowanceAmount,
            newBalanceAgorot: newBalance,
          ),
        );
      } catch (e) {
        result.errors.add(
          'Error processing allowance for ${account.name}: $e',
        );
      }
    }

    // Update app state
    try {
      await DatabaseService.updateAppState('last_allowance_check');
      result.processed = true;
      result.message =
          'Allowance processed for ${result.processedAccounts.length} account(s)';
    } catch (e) {
      result.errors.add('Failed to update app state: $e');
    }

    return result;
  }

  // ============================================================================
  // ANNUAL INTEREST
  // ============================================================================

  /// Process annual interest application
  /// Applied on January 1st
  static Future<InterestResult> processAnnualInterest() async {
    final result = InterestResult();
    final now = DateTime.now();
    final config = await DatabaseService.getConfiguration();

    // Check if today is January 1st
    if (now.month != 1 || now.day != 1) {
      result.processed = false;
      result.message = 'Annual interest only applied on January 1st';
      return result;
    }

    // Check if already processed today
    final lastCheck =
        await DatabaseService.getAppStateLastExecuted('last_interest_applied');
    if (lastCheck != null &&
        lastCheck.year == now.year &&
        lastCheck.month == now.month &&
        lastCheck.day == now.day) {
      result.processed = false;
      result.message = 'Interest already applied today';
      return result;
    }

    // Process interest for each account
    final accounts = await DatabaseService.getAllAccounts();
    for (final account in accounts) {
      try {
        // Calculate interest
        final interest = CalculationService.calculateAnnualInterest(
          account.currentBalanceAgorot,
          config.annualInterestRate,
        );

        if (interest <= 0) {
          continue;
        }

        // Create interest transaction
        final newBalance = account.currentBalanceAgorot + interest;

        await DatabaseService.addTransaction(
          accountId: account.id,
          type: TransactionType.interest,
          amountAgorot: interest,
          postedDate: now,
          balanceAfter: newBalance,
          notes:
              'Annual interest (${config.getInterestRateAsPercent()}%) on balance ${account.formatBalance()}',
          isManual: false,
        );

        result.processedAccounts.add(
          ProcessedAccountRecord(
            accountName: account.name,
            amountAgorot: interest,
            newBalanceAgorot: newBalance,
          ),
        );
      } catch (e) {
        result.errors.add(
          'Error processing interest for ${account.name}: $e',
        );
      }
    }

    // Update app state
    try {
      await DatabaseService.updateAppState('last_interest_applied');
      result.processed = true;
      result.message =
          'Interest applied for ${result.processedAccounts.length} account(s)';
    } catch (e) {
      result.errors.add('Failed to update app state: $e');
    }

    return result;
  }

  // ============================================================================
  // QUARTERLY BONUS
  // ============================================================================

  /// Process quarterly bonus at the end of each quarter
  /// Bonus is applied if there were NO withdrawals during the quarter
  ///
  /// Q1: March 31
  /// Q2: June 30
  /// Q3: September 30
  /// Q4: December 31
  static Future<BonusResult> processQuarterlyBonus(int quarter) async {
    final result = BonusResult(quarter: quarter);
    final now = DateTime.now();
    final config = await DatabaseService.getConfiguration();

    if (quarter < 1 || quarter > 4) {
      result.processed = false;
      result.message = 'Invalid quarter: $quarter';
      return result;
    }

    // Get the end date of this quarter
    final quarterEndDate = CalculationService.getQuarterEndDate(now.year, quarter);

    // Check if today is the last day of the quarter
    final isQuarterEndDay = now.year == quarterEndDate.year &&
        now.month == quarterEndDate.month &&
        now.day == quarterEndDate.day;

    if (!isQuarterEndDay) {
      result.processed = false;
      result.message = 'Bonus applied only on quarter end date';
      return result;
    }

    // Check if already processed today for this quarter
    final stateKey = 'last_bonus_check_q$quarter';
    final lastCheck = await DatabaseService.getAppStateLastExecuted(stateKey);
    if (lastCheck != null &&
        lastCheck.year == now.year &&
        lastCheck.month == now.month &&
        lastCheck.day == now.day) {
      result.processed = false;
      result.message = 'Bonus already processed for Q$quarter today';
      return result;
    }

    // Process bonus for each account
    final accounts = await DatabaseService.getAllAccounts();
    for (final account in accounts) {
      try {
        // Check if account had withdrawals in this quarter
        final hadWithdrawals = await DatabaseService.hasWithdrawalsInQuarter(
          account.id,
          now.year,
          quarter,
        );

        if (hadWithdrawals) {
          result.skippedAccounts.add(
            SkippedAccountRecord(
              accountName: account.name,
              reason: 'Withdrawals detected in Q$quarter',
            ),
          );
          continue;
        }

        // Calculate bonus
        final bonus = CalculationService.calculateQuarterlyBonus(
          account.currentBalanceAgorot,
          config.quarterlyBonusRate,
        );

        if (bonus <= 0) {
          continue;
        }

        // Create bonus transaction
        final newBalance = account.currentBalanceAgorot + bonus;

        await DatabaseService.addTransaction(
          accountId: account.id,
          type: TransactionType.bonus,
          amountAgorot: bonus,
          postedDate: now,
          balanceAfter: newBalance,
          notes:
              'Q$quarter no-withdrawal bonus (${config.getBonusRateAsPercent()}%) - Balance: ${account.formatBalance()}',
          isManual: false,
        );

        result.processedAccounts.add(
          ProcessedAccountRecord(
            accountName: account.name,
            amountAgorot: bonus,
            newBalanceAgorot: newBalance,
          ),
        );
      } catch (e) {
        result.errors.add(
          'Error processing bonus for ${account.name}: $e',
        );
      }
    }

    // Update app state
    try {
      await DatabaseService.updateAppState(stateKey);
      result.processed = true;
      result.message =
          'Bonus applied for ${result.processedAccounts.length} account(s), skipped ${result.skippedAccounts.length}';
    } catch (e) {
      result.errors.add('Failed to update app state: $e');
    }

    return result;
  }

  // ============================================================================
  // SPECIAL CASES
  // ============================================================================

  /// Handle birthday - update age for next allowance
  /// This is typically automatic based on age calculation, but provided
  /// for explicit handling if needed
  static Future<void> handleBirthday(Account account) async {
    // Age is calculated dynamically from dateOfBirth, so no action needed
    // This method exists for potential future use (e.g., logging, notifications)
  }

  /// Manual trigger for testing purposes
  /// Allows forcing automation checks regardless of date
  static Future<AutomationResult> debugRunAllChecks() async {
    return runAllAutomationChecks();
  }
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// Contains results from all automation checks
class AutomationResult {
  late AllowanceResult allowanceResult;
  late InterestResult interestResult;
  late Map<int, BonusResult> bonusResults;
  bool success = false;
  String? error;

  @override
  String toString() => '''
AutomationResult(
  success: $success,
  allowance: ${allowanceResult.message},
  interest: ${interestResult.message},
  bonus Q1: ${bonusResults[1]?.message},
  bonus Q2: ${bonusResults[2]?.message},
  bonus Q3: ${bonusResults[3]?.message},
  bonus Q4: ${bonusResults[4]?.message},
  ${error != null ? 'error: $error' : ''}
)
  ''';
}

/// Base class for automation results
abstract class AutomationCheckResult {
  bool processed = false;
  String message = '';
  List<ProcessedAccountRecord> processedAccounts = [];
  List<String> errors = [];

  bool get hasErrors => errors.isNotEmpty;
}

/// Result from weekly allowance processing
class AllowanceResult extends AutomationCheckResult {}

/// Result from annual interest processing
class InterestResult extends AutomationCheckResult {}

/// Result from quarterly bonus processing
class BonusResult extends AutomationCheckResult {
  final int quarter;
  List<SkippedAccountRecord> skippedAccounts = [];

  BonusResult({required this.quarter});
}

/// Record of a successfully processed account
class ProcessedAccountRecord {
  final String accountName;
  final int amountAgorot;
  final int newBalanceAgorot;

  ProcessedAccountRecord({
    required this.accountName,
    required this.amountAgorot,
    required this.newBalanceAgorot,
  });

  String formatAmount() =>
      CalculationService.formatAgorotAsILS(amountAgorot);

  String formatBalance() =>
      CalculationService.formatAgorotAsILS(newBalanceAgorot);

  @override
  String toString() =>
      '$accountName: +${formatAmount()} → ${formatBalance()}';
}

/// Record of a skipped account
class SkippedAccountRecord {
  final String accountName;
  final String reason;

  SkippedAccountRecord({
    required this.accountName,
    required this.reason,
  });

  @override
  String toString() => '$accountName: $reason';
}
