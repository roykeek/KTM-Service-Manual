// lib/screens/dashboard_screen.dart
// Main dashboard with account cards and transaction actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../providers/database_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_dialogs.dart';
import '../widgets/calculator_widget.dart';
import 'history_screen.dart';
import 'configuration_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  bool _showCalculator = false;

  @override
  Widget build(BuildContext context) {
    final accountSummaries = ref.watch(accountSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Karny Bank',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: KarnyColors.primary,
        elevation: 0,
        actions: [
          // Calculator icon
          Padding(
            padding: const EdgeInsets.only(right: KarnySpacing.md),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showCalculator = !_showCalculator);
                },
                child: const Icon(Icons.calculate_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Calculator overlay (if visible)
                if (_showCalculator)
                  Padding(
                    padding: const EdgeInsets.all(KarnySpacing.lg),
                    child: CalculatorWidget(
                      onClose: () {
                        setState(() => _showCalculator = false);
                      },
                    ),
                  ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(KarnySpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDepositDialog(context, ref);
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Deposit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KarnyColors.success,
                            foregroundColor: KarnyColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: KarnySpacing.md,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: KarnySpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showWithdrawalDialog(context, ref);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KarnyColors.warning,
                            foregroundColor: KarnyColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: KarnySpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Account Cards
                accountSummaries.when(
                  data: (summaries) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summaries.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: KarnySpacing.lg,
                        vertical: KarnySpacing.md,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: KarnySpacing.md,
                          ),
                          child: AccountCard(
                            summary: summaries[index],
                            onViewHistory: () {
                              _selectedIndex = 1;
                              setState(() {});
                              // Navigate with account filter
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HistoryScreen(
                                    preFilterAccountId: summaries[index].id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Error loading accounts: $error'),
                  ),
                ),

                const SizedBox(height: KarnySpacing.lg),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ConfigurationScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
