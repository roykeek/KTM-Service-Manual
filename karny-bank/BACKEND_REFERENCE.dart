// KARNY BANK BACKEND - QUICK REFERENCE GUIDE

/*
================================================================================
                          PROJECT STRUCTURE
================================================================================

lib/
├── services/
│   ├── database_service.dart          ← SQLite CRUD operations
│   ├── calculation_service.dart       ← Financial calculations
│   ├── automation_service.dart        ← Scheduled transactions
│   ├── transaction_service.dart       ← Business logic layer
│   └── database_models.dart           ← Data models & enums
└── main.dart                          ← App initialization

================================================================================
                            QUICK START
================================================================================

1. INITIALIZE DATABASE
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize database
     await DatabaseService.initDatabase();
     
     // Run automation checks on startup
     final result = await AutomationService.runAllAutomationChecks();
     print(result);
     
     runApp(const KarnyBankApp());
   }

2. CREATE ACCOUNTS
   await DatabaseService.createAccount(
     name: 'Or',
     dateOfBirth: DateTime(2016, 1, 21),
   );

3. ADD MANUAL TRANSACTIONS
   // Parent deposits money
   await TransactionService.addManualDeposit(
     accountId: 3,
     amountAgorot: 5000,  // 50 ILS
     notes: 'Birthday gift',
   );

   // Child spends money
   await TransactionService.addManualWithdrawal(
     accountId: 3,
     amountAgorot: 2000,  // 20 ILS
     notes: 'Bought candy',
   );

4. QUERY TRANSACTIONS
   // Get all transactions for an account
   final history = await TransactionService.getAccountHistory(
     accountId: 3,
   );

   // Get deposits only
   final deposits = await TransactionService.getDeposits(
     accountId: 3,
     startDate: DateTime(2025, 1, 1),
     endDate: DateTime(2025, 3, 31),
   );

5. GET STATISTICS
   final stats = await TransactionService.getAccountStatistics(
     accountId: 3,
     startDate: DateTime(2025, 1, 1),
     endDate: DateTime(2025, 12, 31),
   );
   print(stats);

================================================================================
                        MONETARY VALUES (AGOROT)
================================================================================

All money in the app is stored as AGOROT (Israeli cents).

Conversion:
  1 ILS = 100 agorot
  
  14 ILS = 1400 agorot
  2.80 ILS = 280 agorot
  
Formatting:
  CalculationService.formatAgorotAsILS(1400)  →  "₪14.00"
  CalculationService.parseILSToAgorot("14.50")  →  1450

This avoids floating-point precision errors.

================================================================================
                     AUTOMATIC TRANSACTIONS
================================================================================

Weekly Allowance:
  - Triggered: On app startup, if today is configured allowance day
  - Amount: Child's current age in ILS
  - Example: Or (age 9) gets 9 ILS (900 agorot)

Quarterly Bonus:
  - Triggered: On quarter end dates (3/31, 6/30, 9/30, 12/31)
  - Amount: 1.2% of balance (if NO withdrawals in quarter)
  - Skipped: If any withdrawals occurred in quarter

Annual Interest:
  - Triggered: January 1st only
  - Amount: 2.8% of balance, compounded annually
  - Example: 100 ILS → 102.80 ILS

Configuration:
  await DatabaseService.updateConfigValue('annual_interest_rate', '350');  // 3.5%
  await DatabaseService.updateConfigValue('quarterly_bonus_rate', '150');  // 1.5%
  await DatabaseService.updateConfigValue('weekly_allowance_day', '1');    // Monday

================================================================================
                      TRANSACTION FILTERING
================================================================================

By Type:
  TransactionType.manualDeposit
  TransactionType.manualWithdrawal
  TransactionType.allowance
  TransactionType.interest
  TransactionType.bonus

By Account:
  accountId: 1 (Maayan)
  accountId: 2 (Tomer)
  accountId: 3 (Or)

By Date Range:
  startDate: DateTime(2025, 1, 1)
  endDate: DateTime(2025, 12, 31)

Example Query:
  List<Transaction> bonuses = await DatabaseService.getTransactions(
    accountId: 1,
    type: TransactionType.bonus,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 12, 31),
  );

================================================================================
                     BIRTHDAY HANDLING
================================================================================

Birthday Detection:
  account.isBirthdayToday()     // bool

Age Calculation (Automatic):
  account.getAge()              // int

Birthday Effects:
  - Age automatically updates the next day
  - Next weekly allowance uses NEW age
  - No bonus/interest recalculation for past years

Special Case - Birthday on Allowance Day:
  - If birthday falls on (e.g.) Sunday (allowance day)
  - Child still gets allowance with NEW age
  - Handled automatically by CalculationService

================================================================================
                       ERROR HANDLING
================================================================================

Insufficient Funds:
  try {
    await TransactionService.addManualWithdrawal(
      accountId: 3,
      amountAgorot: 999999,
    );
  } catch (e) {
    print('Error: $e');
    // Show user-friendly message
  }

Validation:
  final canWithdraw = await TransactionService.canWithdraw(
    accountId: 3,
    amountAgorot: 2000,
  );

  if (!canWithdraw) {
    print(TransactionService.getInsufficientFundsMessage(account, 2000));
  }

Data Integrity:
  bool isValid = await DatabaseService.verifyDataIntegrity(accountId);
  if (!isValid) {
    // Handle data inconsistency
  }

================================================================================
                       AUDIT TRAIL
================================================================================

When Parent Edits Transaction:
  await DatabaseService.updateTransaction(
    transactionId: 42,
    newAmount: 3000,
    changeReason: 'Incorrect amount entered',
  );

Audit History:
  List<TransactionAudit> history = 
    await DatabaseService.getTransactionAuditHistory(42);

  for (final audit in history) {
    print('${audit.changedAt}: ${audit.previousAmount} → ${audit.newAmount}');
  }

================================================================================
                     FINANCIAL CALCULATIONS
================================================================================

Weekly Allowance:
  int allowance = CalculationService.calculateWeeklyAllowance(account);

Interest:
  int interest = CalculationService.calculateAnnualInterest(
    balanceAgorot: 10000,      // 100 ILS
    annualRateInTenthsOfPercent: 280  // 2.8%
  );

Quarterly Bonus:
  int bonus = CalculationService.calculateQuarterlyBonus(
    balanceAgorot: 10000,
    bonusRateInTenthsOfPercent: 120   // 1.2%
  );

Compound Interest (Over Multiple Years):
  int futureBalance = CalculationService.calculateCompoundInterest(
    principalAgorot: 10000,
    annualRateInTenthsOfPercent: 280,
    years: 5
  );

Quarter Information:
  int quarter = CalculationService.getQuarter(DateTime.now());  // 1-4
  
  DateTime quarterEnd = CalculationService.getQuarterEndDate(2025, 4);
  DateTime quarterStart = CalculationService.getQuarterStartDate(2025, 4);

Day of Week (ISO 8601):
  int dayOfWeek = CalculationService.getDayOfWeekIso8601(date);
  // 0=Sunday, 1=Monday, ..., 6=Saturday

Statistics:
  TransactionStatistics stats = CalculationService.getTransactionStatistics(transactions);
  print(stats.totalDeposits);
  print(stats.totalWithdrawals);
  print(stats.averageDeposit);

================================================================================
                        EXPORT & REPORTING
================================================================================

Export as CSV:
  String csv = await TransactionService.exportTransactionsAsCSV(
    accountId: 1,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 12, 31),
  );
  // Save to file or share

Account Summary:
  AccountSummary? summary = await DatabaseService.getAccountSummary(1);
  if (summary != null) {
    print('Name: ${summary.name}');
    print('Balance: ${summary.currentBalanceAgorot}');
    print('Last Deposit: ${summary.lastDepositDate}');
  }

Next Allowance:
  String info = await TransactionService.getNextAllowanceInfo();
  // "Allowance is deposited today (Sunday)!"

Next Bonus Dates:
  List<String> dates = await TransactionService.getNextBonusDates();
  // ["Q1: 3/31 (in 78 days)", "Q2: 6/30 (in 168 days)", ...]

================================================================================
                     TESTING & DEBUGGING
================================================================================

Force Run Automation:
  AutomationResult result = await AutomationService.debugRunAllChecks();
  print(result.allowanceResult.message);
  print(result.interestResult.message);
  print(result.bonusResults[1].message);

Check App State:
  DateTime? lastAllowance = 
    await DatabaseService.getAppStateLastExecuted('last_allowance_check');
  print('Last allowance check: $lastAllowance');

Verify Database Integrity:
  bool valid = await DatabaseService.verifyDataIntegrity(1);
  print('Data integrity: $valid');

Close Database (Cleanup):
  await DatabaseService.closeDatabase();

================================================================================
                       KEY FEATURES
================================================================================

✓ Secure: Past transactions immutable, audit trail preserved
✓ Accurate: Fixed-point arithmetic (agorot) prevents rounding errors
✓ Automated: Allowances, interest, bonuses on schedule
✓ Transparent: Complete history with dates and balances
✓ Flexible: Parent can configure rates and allowance day
✓ Robust: Data integrity checks, error handling, cascading updates
✓ Educational: Financial calculations exposed for learning
✓ Offline-first: All data local in SQLite, no server needed

================================================================================
*/
