// lib/models/database_models.dart
// Dart models corresponding to Karny Bank SQLite schema
// All monetary values in agorot (Israeli cents)

import 'package:intl/intl.dart';

enum TransactionType {
  allowance,
  interest,
  bonus,
  manualDeposit,
  manualWithdrawal;

  String toDbString() {
    switch (this) {
      case TransactionType.allowance:
        return 'ALLOWANCE';
      case TransactionType.interest:
        return 'INTEREST';
      case TransactionType.bonus:
        return 'BONUS';
      case TransactionType.manualDeposit:
        return 'MANUAL_DEPOSIT';
      case TransactionType.manualWithdrawal:
        return 'MANUAL_WITHDRAWAL';
    }
  }

  static TransactionType fromDbString(String value) {
    switch (value) {
      case 'ALLOWANCE':
        return TransactionType.allowance;
      case 'INTEREST':
        return TransactionType.interest;
      case 'BONUS':
        return TransactionType.bonus;
      case 'MANUAL_DEPOSIT':
        return TransactionType.manualDeposit;
      case 'MANUAL_WITHDRAWAL':
        return TransactionType.manualWithdrawal;
      default:
        throw ArgumentError('Unknown transaction type: $value');
    }
  }

  String displayName() {
    switch (this) {
      case TransactionType.allowance:
        return 'Allowance';
      case TransactionType.interest:
        return 'Interest';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.manualDeposit:
        return 'Manual Deposit';
      case TransactionType.manualWithdrawal:
        return 'Manual Withdrawal';
    }
  }
}

/// Represents a child account
class Account {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final int currentBalanceAgorot; // in agorot (Israeli cents)
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.currentBalanceAgorot,
    required this.createdAt,
  });

  /// Get child's current age
  int getAge() {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Check if today is the child's birthday
  bool isBirthdayToday() {
    final now = DateTime.now();
    return now.month == dateOfBirth.month && now.day == dateOfBirth.day;
  }

  /// Format balance as ILS string (agorot to ILS)
  String formatBalance() {
    final ils = currentBalanceAgorot / 100;
    return NumberFormat.currency(locale: 'he_IL', symbol: '₪').format(ils);
  }

  /// Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'current_balance': currentBalanceAgorot,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create Account from database Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      name: map['name'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      currentBalanceAgorot: map['current_balance'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'Account(id: $id, name: $name, balance: ${formatBalance()}, age: ${getAge()})';
}

/// Represents a single transaction
class Transaction {
  final int id;
  final int accountId;
  final TransactionType type;
  final int amountAgorot; // in agorot
  final DateTime postedDate;
  final DateTime transactionDatetime;
  final int balanceAfter; // snapshot of balance after transaction
  final String? notes;
  final bool isManual;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amountAgorot,
    required this.postedDate,
    required this.transactionDatetime,
    required this.balanceAfter,
    this.notes,
    required this.isManual,
    required this.createdAt,
  });

  /// Format amount as ILS string
  String formatAmount() {
    final ils = amountAgorot / 100;
    return NumberFormat.currency(locale: 'he_IL', symbol: '₪').format(ils);
  }

  /// Format balance as ILS string
  String formatBalanceAfter() {
    final ils = balanceAfter / 100;
    return NumberFormat.currency(locale: 'he_IL', symbol: '₪').format(ils);
  }

  /// Determine if transaction is a deposit or withdrawal
  bool isDeposit() {
    return type == TransactionType.allowance ||
        type == TransactionType.interest ||
        type == TransactionType.bonus ||
        type == TransactionType.manualDeposit;
  }

  bool isWithdrawal() => type == TransactionType.manualWithdrawal;

  /// Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'type': type.toDbString(),
      'amount': amountAgorot,
      'posted_date': postedDate.toIso8601String().split('T')[0],
      'transaction_datetime': transactionDatetime.toIso8601String(),
      'balance_after': balanceAfter,
      'notes': notes,
      'is_manual': isManual ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create Transaction from database Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int,
      accountId: map['account_id'] as int,
      type: TransactionType.fromDbString(map['type'] as String),
      amountAgorot: map['amount'] as int,
      postedDate: DateTime.parse(map['posted_date'] as String),
      transactionDatetime: DateTime.parse(map['transaction_datetime'] as String),
      balanceAfter: map['balance_after'] as int,
      notes: map['notes'] as String?,
      isManual: (map['is_manual'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, type: ${type.displayName()}, amount: ${formatAmount()}, date: ${postedDate.toString().split(' ')[0]})';
}

/// Represents a transaction audit log entry
class TransactionAudit {
  final int id;
  final int transactionId;
  final String changedBy;
  final DateTime changedAt;
  final int previousAmount; // in agorot
  final int newAmount; // in agorot
  final String? changeReason;

  TransactionAudit({
    required this.id,
    required this.transactionId,
    required this.changedBy,
    required this.changedAt,
    required this.previousAmount,
    required this.newAmount,
    this.changeReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'changed_by': changedBy,
      'changed_at': changedAt.toIso8601String(),
      'previous_amount': previousAmount,
      'new_amount': newAmount,
      'change_reason': changeReason,
    };
  }

  factory TransactionAudit.fromMap(Map<String, dynamic> map) {
    return TransactionAudit(
      id: map['id'] as int,
      transactionId: map['transaction_id'] as int,
      changedBy: map['changed_by'] as String,
      changedAt: DateTime.parse(map['changed_at'] as String),
      previousAmount: map['previous_amount'] as int,
      newAmount: map['new_amount'] as int,
      changeReason: map['change_reason'] as String?,
    );
  }
}

/// Represents configuration settings
class AppConfiguration {
  int annualInterestRate; // stored as integer (e.g., 280 = 2.8%)
  int quarterlyBonusRate; // stored as integer (e.g., 120 = 1.2%)
  int weeklyAllowanceDay; // 0=Sunday, 1=Monday, etc.

  AppConfiguration({
    required this.annualInterestRate,
    required this.quarterlyBonusRate,
    required this.weeklyAllowanceDay,
  });

  double getInterestRateAsPercent() => annualInterestRate / 100;

  double getBonusRateAsPercent() => quarterlyBonusRate / 100;

  String getAllowanceDayName() {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[weeklyAllowanceDay];
  }
}

/// App state for tracking automation execution
class AppState {
  final String key;
  final DateTime? lastExecuted;
  final DateTime lastExecutedDatetime;

  AppState({
    required this.key,
    this.lastExecuted,
    required this.lastExecutedDatetime,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'last_executed':
          lastExecuted?.toIso8601String().split('T')[0], // date only
      'last_executed_datetime': lastExecutedDatetime.toIso8601String(),
    };
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(
      key: map['key'] as String,
      lastExecuted: map['last_executed'] != null
          ? DateTime.parse(map['last_executed'] as String)
          : null,
      lastExecutedDatetime:
          DateTime.parse(map['last_executed_datetime'] as String),
    );
  }
}

/// View model for account summary (from v_account_summary view)
class AccountSummary {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final int currentBalanceAgorot;
  final DateTime? lastDepositDate;
  final int? lastDepositAmount;
  final DateTime? lastWithdrawalDate;
  final int? lastWithdrawalAmount;

  AccountSummary({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.currentBalanceAgorot,
    this.lastDepositDate,
    this.lastDepositAmount,
    this.lastWithdrawalDate,
    this.lastWithdrawalAmount,
  });

  int getAge() {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  factory AccountSummary.fromMap(Map<String, dynamic> map) {
    return AccountSummary(
      id: map['id'] as int,
      name: map['name'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      currentBalanceAgorot: map['current_balance'] as int,
      lastDepositDate: map['last_deposit_date'] != null
          ? DateTime.parse(map['last_deposit_date'] as String)
          : null,
      lastDepositAmount: map['last_deposit_amount'] as int?,
      lastWithdrawalDate: map['last_withdrawal_date'] != null
          ? DateTime.parse(map['last_withdrawal_date'] as String)
          : null,
      lastWithdrawalAmount: map['last_withdrawal_amount'] as int?,
    );
  }
}
