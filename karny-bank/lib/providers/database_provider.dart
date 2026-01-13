// lib/providers/database_provider.dart
// Riverpod providers for database and business logic state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/transaction_service.dart';
import '../services/automation_service.dart';
import '../services/database_models.dart';

// Database initialization
final databaseProvider = FutureProvider<void>((ref) async {
  await DatabaseService.initDatabase();
});

// All accounts
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  // Depend on database provider to ensure it's initialized
  await ref.watch(databaseProvider.future);
  return DatabaseService.getAllAccounts();
});

// Account summaries (for dashboard)
final accountSummariesProvider = FutureProvider<List<AccountSummary>>((ref) async {
  await ref.watch(databaseProvider.future);
  return DatabaseService.getAllAccountSummaries();
});

// Single account detail
final accountProvider = FutureProvider.family<Account?, int>((ref, accountId) async {
  await ref.watch(databaseProvider.future);
  return DatabaseService.getAccountById(accountId);
});

// Configuration
final configurationProvider = FutureProvider<AppConfiguration>((ref) async {
  await ref.watch(databaseProvider.future);
  return DatabaseService.getConfiguration();
});

// Transaction history with filters
final transactionHistoryProvider = FutureProvider.family<
    List<Transaction>,
    ({int? accountId, TransactionType? type, DateTime? startDate, DateTime? endDate})>((ref, params) async {
  await ref.watch(databaseProvider.future);
  return DatabaseService.getTransactions(
    accountId: params.accountId,
    type: params.type,
    startDate: params.startDate,
    endDate: params.endDate,
    limit: 1000,
  );
});

// All transactions
final allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  await ref.watch(databaseProvider.future);
  final accounts = await ref.watch(accountsProvider.future);
  final allTransactions = <Transaction>[];

  for (final account in accounts) {
    final txns = await DatabaseService.getTransactions(
      accountId: account.id,
      limit: 1000,
    );
    allTransactions.addAll(txns);
  }

  allTransactions.sort((a, b) => b.postedDate.compareTo(a.postedDate));
  return allTransactions;
});

// Account statistics
final accountStatisticsProvider = FutureProvider.family<
    AccountStatistics,
    ({int accountId, DateTime startDate, DateTime endDate})>((ref, params) async {
  await ref.watch(databaseProvider.future);
  return TransactionService.getAccountStatistics(
    accountId: params.accountId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Automation results
final automationProvider = FutureProvider<AutomationResult>((ref) async {
  await ref.watch(databaseProvider.future);
  return AutomationService.runAllAutomationChecks();
});

// State notifiers for UI state

class RefreshNotifier extends StateNotifier<bool> {
  RefreshNotifier() : super(false);

  void trigger() {
    state = !state;
  }
}

final refreshTriggerProvider = StateNotifierProvider<RefreshNotifier, bool>((ref) {
  return RefreshNotifier();
});

// Use this to invalidate and refresh all data
void refreshAllData(WidgetRef ref) {
  ref.invalidate(accountSummariesProvider);
  ref.invalidate(allTransactionsProvider);
  ref.invalidate(transactionHistoryProvider);
  ref.invalidate(automationProvider);
}
