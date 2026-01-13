// lib/widgets/account_card.dart
// Individual account card for dashboard

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../services/database_models.dart';
import '../services/calculation_service.dart';

class AccountCard extends StatelessWidget {
  final AccountSummary summary;
  final VoidCallback onViewHistory;

  const AccountCard({
    Key? key,
    required this.summary,
    required this.onViewHistory,
  }) : super(key: key);

  String _getInitials() => summary.name.substring(0, 1).toUpperCase();

  String _formatBalance() {
    final ils = summary.currentBalanceAgorot / 100;
    return '₪${ils.toStringAsFixed(2)}';
  }

  String _formatLastTransaction(DateTime? date, int? amount) {
    if (date == null || amount == null) return 'None';
    final ils = amount / 100;
    final formatted = DateFormat('MMM dd').format(date);
    return '₪$ils ($formatted)';
  }

  Color _getAgeColor() {
    final age = summary.getAge();
    if (age <= 10) return KarnyColors.success; // Or
    if (age <= 13) return KarnyColors.info; // Tomer
    return KarnyColors.primary; // Maayan
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(KarnySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Age
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getAgeColor(),
                  child: Text(
                    _getInitials(),
                    style: const TextStyle(
                      fontSize: KarnyFontSize.xxl,
                      fontWeight: FontWeight.bold,
                      color: KarnyColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: KarnySpacing.md),
                // Name and Age
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.name,
                        style: const TextStyle(
                          fontSize: KarnyFontSize.lg,
                          fontWeight: FontWeight.bold,
                          color: KarnyColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Age ${summary.getAge()}',
                        style: const TextStyle(
                          fontSize: KarnyFontSize.sm,
                          color: KarnyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: KarnySpacing.md),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: KarnyFontSize.sm,
                    color: KarnyColors.textSecondary,
                  ),
                ),
                Text(
                  _formatBalance(),
                  style: const TextStyle(
                    fontSize: KarnyFontSize.xxxl,
                    fontWeight: FontWeight.bold,
                    color: KarnyColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: KarnySpacing.lg),

            // Last Transactions
            Row(
              children: [
                // Last Deposit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Deposit',
                        style: TextStyle(
                          fontSize: KarnyFontSize.xs,
                          color: KarnyColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatLastTransaction(
                          summary.lastDepositDate,
                          summary.lastDepositAmount,
                        ),
                        style: const TextStyle(
                          fontSize: KarnyFontSize.sm,
                          color: KarnyColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KarnySpacing.md),
                // Last Withdrawal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Withdrawal',
                        style: TextStyle(
                          fontSize: KarnyFontSize.xs,
                          color: KarnyColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatLastTransaction(
                          summary.lastWithdrawalDate,
                          summary.lastWithdrawalAmount,
                        ),
                        style: const TextStyle(
                          fontSize: KarnyFontSize.sm,
                          color: KarnyColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: KarnySpacing.md),

            // View History Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onViewHistory,
                style: TextButton.styleFrom(
                  foregroundColor: KarnyColors.primary,
                ),
                child: const Text('View Full History →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
