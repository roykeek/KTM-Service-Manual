// lib/widgets/transaction_dialogs.dart
// Reusable dialogs for deposits and withdrawals

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../providers/database_provider.dart';
import '../services/transaction_service.dart';
import '../services/calculation_service.dart';
import 'financial_tips_dialog.dart';

void showDepositDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => _TransactionDialog(
      title: 'Deposit Money',
      type: 'deposit',
      ref: ref,
    ),
  );
}

void showWithdrawalDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => _TransactionDialog(
      title: 'Withdraw Money',
      type: 'withdrawal',
      ref: ref,
    ),
  );
}

class _TransactionDialog extends ConsumerStatefulWidget {
  final String title;
  final String type;
  final WidgetRef ref;

  const _TransactionDialog({
    required this.title,
    required this.type,
    required this.ref,
  });

  @override
  ConsumerState<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends ConsumerState<_TransactionDialog> {
  int? selectedAccountId;
  final amountController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (selectedAccountId == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final amountIls = double.parse(amountController.text);
      final amountAgorot = (amountIls * 100).toInt();

      if (widget.type == 'deposit') {
        await TransactionService.addManualDeposit(
          accountId: selectedAccountId!,
          amountAgorot: amountAgorot,
        );

        // Show success and financial tip
        if (!mounted) return;
        Navigator.of(context).pop();

        _showSuccessAndTip(
          context: context,
          message: 'Deposit successful!',
          amount: '₪${amountIls.toStringAsFixed(2)}',
          accountId: selectedAccountId!,
        );
      } else {
        // Check if sufficient funds
        final canWithdraw = await TransactionService.canWithdraw(
          selectedAccountId!,
          amountAgorot,
        );

        if (!canWithdraw) {
          if (!mounted) return;
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient funds!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await TransactionService.addManualWithdrawal(
          accountId: selectedAccountId!,
          amountAgorot: amountAgorot,
        );

        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal of ₪${amountIls.toStringAsFixed(2)} successful!'),
          ),
        );
      }

      // Refresh data
      refreshAllData(ref);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showSuccessAndTip({
    required BuildContext context,
    required String message,
    required String amount,
    required int accountId,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message $amount')),
    );

    // Show financial tip after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showFinancialTipDialog(context, accountId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    return AlertDialog(
      title: Text(widget.title),
      content: accounts.when(
        data: (accountsList) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account Dropdown
              DropdownButtonFormField<int>(
                value: selectedAccountId,
                hint: const Text('Select Account'),
                items: accountsList
                    .map((account) => DropdownMenuItem(
                          value: account.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: KarnyColors.primary,
                                child: Text(
                                  account.name[0],
                                  style: const TextStyle(
                                    color: KarnyColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: KarnySpacing.md),
                              Text(account.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedAccountId = value);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KarnyRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: KarnySpacing.md),
              // Amount Input
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (ILS)',
                  prefixText: '₪ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KarnyRadius.md),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.type == 'deposit'
                ? KarnyColors.success
                : KarnyColors.warning,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.title.split(' ')[0]),
        ),
      ],
    );
  }
}
