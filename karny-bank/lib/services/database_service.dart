// lib/services/database_service.dart
// Core SQLite database operations for Karny Bank
// Handles all CRUD operations and queries

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_models.dart';

class DatabaseService {
  static Database? _db;
  static const String dbName = 'karny_bank.db';

  /// Initialize database and run migrations
  static Future<Database> initDatabase() async {
    if (_db != null) return _db!;

    final databasePath = await getDatabasesPath();
    final dbPath = join(databasePath, dbName);

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await _createSchema(db);
      },
    );

    return _db!;
  }

  /// Get database instance
  static Future<Database> getDb() async {
    return _db ?? await initDatabase();
  }

  /// Create all tables and initial configuration
  static Future<void> _createSchema(Database db) async {
    // Accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        date_of_birth DATE NOT NULL,
        current_balance INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CHECK (current_balance >= 0)
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        type TEXT NOT NULL CHECK (type IN (
          'ALLOWANCE',
          'INTEREST',
          'BONUS',
          'MANUAL_DEPOSIT',
          'MANUAL_WITHDRAWAL'
        )),
        amount INTEGER NOT NULL,
        posted_date DATE NOT NULL,
        transaction_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        balance_after INTEGER NOT NULL,
        notes TEXT,
        is_manual BOOLEAN NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE RESTRICT,
        CHECK (amount > 0),
        CHECK (balance_after >= 0)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_account_id ON transactions(account_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_posted_date ON transactions(posted_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_type ON transactions(type)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_account_posted ON transactions(account_id, posted_date)
    ''');

    // Transactions audit table
    await db.execute('''
      CREATE TABLE transactions_audit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        changed_by TEXT NOT NULL DEFAULT 'parent',
        changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        previous_amount INTEGER NOT NULL,
        new_amount INTEGER NOT NULL,
        change_reason TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_audit_transaction_id ON transactions_audit(transaction_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_audit_changed_at ON transactions_audit(changed_at)
    ''');

    // Configuration table
    await db.execute('''
      CREATE TABLE configuration (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // App state table
    await db.execute('''
      CREATE TABLE app_state (
        key TEXT PRIMARY KEY,
        last_executed DATE,
        last_executed_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default configuration
    await db.execute('''
      INSERT INTO configuration (key, value) VALUES
      ('annual_interest_rate', '280'),
      ('quarterly_bonus_rate', '120'),
      ('weekly_allowance_day', '0')
    ''');

    // Initialize app state keys
    final stateKeys = [
      'last_allowance_check',
      'last_interest_applied',
      'last_bonus_check_q1',
      'last_bonus_check_q2',
      'last_bonus_check_q3',
      'last_bonus_check_q4',
    ];
    for (final key in stateKeys) {
      await db.execute('''
        INSERT INTO app_state (key) VALUES ('$key')
      ''');
    }
  }

  // ============================================================================
  // ACCOUNT OPERATIONS
  // ============================================================================

  /// Create a new account
  static Future<int> createAccount({
    required String name,
    required DateTime dateOfBirth,
  }) async {
    final db = await getDb();
    return await db.insert(
      'accounts',
      {
        'name': name,
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        'current_balance': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get all accounts
  static Future<List<Account>> getAllAccounts() async {
    final db = await getDb();
    final maps = await db.query('accounts', orderBy: 'id ASC');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  /// Get account by ID
  static Future<Account?> getAccountById(int accountId) async {
    final db = await getDb();
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
    if (maps.isEmpty) return null;
    return Account.fromMap(maps.first);
  }

  /// Get account by name
  static Future<Account?> getAccountByName(String name) async {
    final db = await getDb();
    final maps = await db.query(
      'accounts',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) return null;
    return Account.fromMap(maps.first);
  }

  /// Update account balance (internal use only)
  static Future<void> updateAccountBalance(
    int accountId,
    int newBalance,
  ) async {
    final db = await getDb();
    await db.update(
      'accounts',
      {'current_balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  // ============================================================================
  // TRANSACTION OPERATIONS
  // ============================================================================

  /// Add a transaction
  static Future<int> addTransaction({
    required int accountId,
    required TransactionType type,
    required int amountAgorot,
    required DateTime postedDate,
    required int balanceAfter,
    String? notes,
    bool isManual = false,
  }) async {
    final db = await getDb();

    // Validate withdrawal doesn't exceed balance
    if (type == TransactionType.manualWithdrawal) {
      final previousBalance = balanceAfter + amountAgorot;
      if (amountAgorot > previousBalance) {
        throw Exception(
          'Insufficient funds: withdrawal of $amountAgorot exceeds balance of $previousBalance',
        );
      }
    }

    // Insert transaction
    final transactionId = await db.insert(
      'transactions',
      {
        'account_id': accountId,
        'type': type.toDbString(),
        'amount': amountAgorot,
        'posted_date': postedDate.toIso8601String().split('T')[0],
        'transaction_datetime': DateTime.now().toIso8601String(),
        'balance_after': balanceAfter,
        'notes': notes,
        'is_manual': isManual ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // Update account balance
    await updateAccountBalance(accountId, balanceAfter);

    return transactionId;
  }

  /// Get all transactions for an account, optionally filtered
  static Future<List<Transaction>> getTransactions({
    int? accountId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
    int offset = 0,
  }) async {
    final db = await getDb();

    String where = '1=1';
    final whereArgs = <dynamic>[];

    if (accountId != null) {
      where += ' AND account_id = ?';
      whereArgs.add(accountId);
    }

    if (type != null) {
      where += ' AND type = ?';
      whereArgs.add(type.toDbString());
    }

    if (startDate != null) {
      where += ' AND posted_date >= ?';
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      where += ' AND posted_date <= ?';
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final maps = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'posted_date DESC, transaction_datetime DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  /// Get transaction by ID
  static Future<Transaction?> getTransactionById(int transactionId) async {
    final db = await getDb();
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  /// Update a transaction and create audit log
  static Future<void> updateTransaction({
    required int transactionId,
    required int newAmount,
    String? changeReason,
  }) async {
    final db = await getDb();

    // Get original transaction
    final original = await getTransactionById(transactionId);
    if (original == null) throw Exception('Transaction not found');

    // Create audit entry
    await db.insert('transactions_audit', {
      'transaction_id': transactionId,
      'changed_by': 'parent',
      'changed_at': DateTime.now().toIso8601String(),
      'previous_amount': original.amountAgorot,
      'new_amount': newAmount,
      'change_reason': changeReason,
    });

    // Calculate new balance
    final difference = newAmount - original.amountAgorot;
    final newBalance = original.balanceAfter + difference;

    // Update transaction
    await db.update(
      'transactions',
      {
        'amount': newAmount,
        'balance_after': newBalance,
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    // Update account balance
    await updateAccountBalance(original.accountId, newBalance);

    // Cascade update all subsequent transactions
    await _cascadeUpdateBalances(original.accountId, transactionId, difference);
  }

  /// Internal: update balances for all transactions after a modified one
  static Future<void> _cascadeUpdateBalances(
    int accountId,
    int afterTransactionId,
    int difference,
  ) async {
    final db = await getDb();

    final affectedTransactions = await db.query(
      'transactions',
      where: 'account_id = ? AND id > ?',
      whereArgs: [accountId, afterTransactionId],
      orderBy: 'posted_date ASC, transaction_datetime ASC',
    );

    for (final map in affectedTransactions) {
      final newBalance = (map['balance_after'] as int) + difference;
      await db.update(
        'transactions',
        {'balance_after': newBalance},
        where: 'id = ?',
        whereArgs: [map['id']],
      );
    }
  }

  /// Get transactions for a specific quarter
  static Future<List<Transaction>> getTransactionsForQuarter(
    int accountId,
    int year,
    int quarter,
  ) async {
    final monthStart = (quarter - 1) * 3 + 1;
    final monthEnd = quarter * 3;

    final startDate = DateTime(year, monthStart, 1);
    final endDate = DateTime(year, monthEnd + 1, 0);

    return getTransactions(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Check if account had withdrawals in a quarter
  static Future<bool> hasWithdrawalsInQuarter(
    int accountId,
    int year,
    int quarter,
  ) async {
    final transactions =
        await getTransactionsForQuarter(accountId, year, quarter);
    return transactions
        .any((t) => t.type == TransactionType.manualWithdrawal);
  }

  /// Get transaction audit history
  static Future<List<TransactionAudit>> getTransactionAuditHistory(
    int transactionId,
  ) async {
    final db = await getDb();
    final maps = await db.query(
      'transactions_audit',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'changed_at DESC',
    );
    return List.generate(
      maps.length,
      (i) => TransactionAudit.fromMap(maps[i]),
    );
  }

  // ============================================================================
  // CONFIGURATION OPERATIONS
  // ============================================================================

  /// Get configuration value
  static Future<String?> getConfigValue(String key) async {
    final db = await getDb();
    final maps = await db.query(
      'configuration',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  /// Get all configuration
  static Future<AppConfiguration> getConfiguration() async {
    final interestRate = await getConfigValue('annual_interest_rate');
    final bonusRate = await getConfigValue('quarterly_bonus_rate');
    final allowanceDay = await getConfigValue('weekly_allowance_day');

    return AppConfiguration(
      annualInterestRate: int.parse(interestRate ?? '280'),
      quarterlyBonusRate: int.parse(bonusRate ?? '120'),
      weeklyAllowanceDay: int.parse(allowanceDay ?? '0'),
    );
  }

  /// Update configuration value
  static Future<void> updateConfigValue(String key, String value) async {
    final db = await getDb();
    await db.update(
      'configuration',
      {
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // ============================================================================
  // APP STATE OPERATIONS
  // ============================================================================

  /// Get app state value
  static Future<DateTime?> getAppStateLastExecuted(String key) async {
    final db = await getDb();
    final maps = await db.query(
      'app_state',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    final dateStr = maps.first['last_executed'] as String?;
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  /// Update app state
  static Future<void> updateAppState(String key) async {
    final db = await getDb();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await db.update(
      'app_state',
      {
        'last_executed': today,
        'last_executed_datetime': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // ============================================================================
  // REPORTING & VIEWS
  // ============================================================================

  /// Get account summary (mimics v_account_summary view)
  static Future<AccountSummary?> getAccountSummary(int accountId) async {
    final db = await getDb();
    final account = await getAccountById(accountId);
    if (account == null) return null;

    // Get last deposit
    final lastDeposits = await db.rawQuery('''
      SELECT posted_date, amount FROM transactions
      WHERE account_id = ? AND type IN ('MANUAL_DEPOSIT', 'ALLOWANCE', 'INTEREST', 'BONUS')
      ORDER BY posted_date DESC LIMIT 1
    ''', [accountId]);

    // Get last withdrawal
    final lastWithdrawals = await db.rawQuery('''
      SELECT posted_date, amount FROM transactions
      WHERE account_id = ? AND type = 'MANUAL_WITHDRAWAL'
      ORDER BY posted_date DESC LIMIT 1
    ''', [accountId]);

    return AccountSummary(
      id: account.id,
      name: account.name,
      dateOfBirth: account.dateOfBirth,
      currentBalanceAgorot: account.currentBalanceAgorot,
      lastDepositDate: lastDeposits.isNotEmpty
          ? DateTime.parse(lastDeposits.first['posted_date'] as String)
          : null,
      lastDepositAmount: lastDeposits.isNotEmpty
          ? lastDeposits.first['amount'] as int
          : null,
      lastWithdrawalDate: lastWithdrawals.isNotEmpty
          ? DateTime.parse(lastWithdrawals.first['posted_date'] as String)
          : null,
      lastWithdrawalAmount: lastWithdrawals.isNotEmpty
          ? lastWithdrawals.first['amount'] as int
          : null,
    );
  }

  /// Get all account summaries
  static Future<List<AccountSummary>> getAllAccountSummaries() async {
    final accounts = await getAllAccounts();
    final summaries = <AccountSummary>[];
    for (final account in accounts) {
      final summary = await getAccountSummary(account.id);
      if (summary != null) summaries.add(summary);
    }
    return summaries;
  }

  /// Verify data integrity
  static Future<bool> verifyDataIntegrity(int accountId) async {
    final db = await getDb();
    final account = await getAccountById(accountId);
    if (account == null) return false;

    final transactions = await getTransactions(accountId: accountId);
    if (transactions.isEmpty) return account.currentBalanceAgorot == 0;

    // Calculate expected balance from transactions
    int calculatedBalance = 0;
    for (final txn in transactions.reversed) {
      if (txn.isDeposit()) {
        calculatedBalance += txn.amountAgorot;
      } else if (txn.isWithdrawal()) {
        calculatedBalance -= txn.amountAgorot;
      }
    }

    return calculatedBalance == account.currentBalanceAgorot;
  }

  /// Close database
  static Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
