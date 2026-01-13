// lib/screens/history_screen.dart
// Transaction history with filtering and sorting

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../providers/database_provider.dart';
import '../services/database_models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final int? preFilterAccountId;

  const HistoryScreen({
    Key? key,
    this.preFilterAccountId,
  }) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int? _selectedAccountId;
  List<TransactionType> _selectedTypes = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.preFilterAccountId;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 90)),
              end: DateTime.now(),
            ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all accounts for filter dropdown
    final accounts = ref.watch(accountsProvider);

    // Fetch transactions with current filters
    final transactionsData = ref.watch(
      transactionHistoryProvider(
        (
          accountId: _selectedAccountId,
          type: _selectedTypes.isEmpty ? null : _selectedTypes.first,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    // Filter transactions client-side if multiple types selected
    final filteredTransactions = transactionsData.maybeWhen(
      data: (transactions) {
        if (_selectedTypes.isEmpty) return transactions;
        return transactions
            .where((t) => _selectedTypes.contains(t.type))
            .toList();
      },
      orElse: () => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: KarnyColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filters (Collapsible)
            if (_showFilters) _buildFiltersPanel(context, accounts),

            // Transaction list
            transactionsData.when(
              data: (transactions) {
                if (filteredTransactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: KarnySpacing.xxl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: KarnyColors.grey,
                          ),
                          const SizedBox(height: KarnySpacing.md),
                          const Text(
                            'No transactions found',
                            style: TextStyle(color: KarnyColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  padding: const EdgeInsets.all(KarnySpacing.lg),
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionRow(context, transaction);
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: KarnySpacing.xxl),
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: KarnySpacing.xxl),
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(BuildContext context, AsyncValue<List<Account>> accounts) {
    return Container(
      padding: const EdgeInsets.all(KarnySpacing.lg),
      decoration: const BoxDecoration(
        color: KarnyColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Filter
          const Text(
            'Account Owner',
            style: TextStyle(
              fontSize: KarnyFontSize.md,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KarnySpacing.sm),
          accounts.when(
            data: (accountsList) => DropdownButton<int?>(
              value: _selectedAccountId,
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Accounts'),
                ),
                ...accountsList
                    .map((account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ))
                    .toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedAccountId = value);
              },
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: KarnySpacing.md),

          // Transaction Type Filter
          const Text(
            'Transaction Type',
            style: TextStyle(
              fontSize: KarnyFontSize.md,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KarnySpacing.sm),
          Wrap(
            spacing: KarnySpacing.sm,
            children: [
              FilterChip(
                label: const Text('Deposits'),
                selected: _selectedTypes.isEmpty || _selectedTypes.contains(TransactionType.manualDeposit),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(TransactionType.manualDeposit);
                      _selectedTypes.add(TransactionType.allowance);
                      _selectedTypes.add(TransactionType.interest);
                      _selectedTypes.add(TransactionType.bonus);
                    } else {
                      _selectedTypes.clear();
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Withdrawals'),
                selected: _selectedTypes.contains(TransactionType.manualWithdrawal),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(TransactionType.manualWithdrawal);
                    } else {
                      _selectedTypes.remove(TransactionType.manualWithdrawal);
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Allowance'),
                selected: _selectedTypes.contains(TransactionType.allowance),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(TransactionType.allowance);
                    } else {
                      _selectedTypes.remove(TransactionType.allowance);
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Interest'),
                selected: _selectedTypes.contains(TransactionType.interest),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(TransactionType.interest);
                    } else {
                      _selectedTypes.remove(TransactionType.interest);
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Bonus'),
                selected: _selectedTypes.contains(TransactionType.bonus),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(TransactionType.bonus);
                    } else {
                      _selectedTypes.remove(TransactionType.bonus);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: KarnySpacing.md),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: KarnyFontSize.md,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KarnySpacing.sm),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KarnySpacing.md,
                vertical: KarnySpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: KarnyColors.grey),
                borderRadius: BorderRadius.circular(KarnyRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                        : 'Select date range',
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, Transaction transaction) {
    final isDeposit = transaction.isDeposit();
    final amountColor = isDeposit ? KarnyColors.success : KarnyColors.warning;
    final amountSign = isDeposit ? '+' : '-';
    final amount = transaction.amountAgorot / 100;
    final balance = transaction.balanceAfter / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: KarnySpacing.md),
      padding: const EdgeInsets.all(KarnySpacing.md),
      decoration: BoxDecoration(
        color: KarnyColors.white,
        borderRadius: BorderRadius.circular(KarnyRadius.md),
        border: Border.all(color: KarnyColors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(KarnySpacing.md),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
            ),
          ),
          const SizedBox(width: KarnySpacing.md),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: KarnyColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy - HH:mm').format(transaction.postedDate),
                  style: const TextStyle(
                    fontSize: KarnyFontSize.sm,
                    color: KarnyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountSign₪${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: KarnyFontSize.lg,
                ),
              ),
              Text(
                'Balance: ₪${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: KarnyFontSize.xs,
                  color: KarnyColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
