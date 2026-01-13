// lib/main.dart - Complete Example Implementation
// This demonstrates how to use all the backend services

import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'services/transaction_service.dart';
import 'services/automation_service.dart';
import 'services/calculation_service.dart';
import 'services/database_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService.initDatabase();

  // Initialize sample accounts (only on first run)
  await _initializeSampleData();

  // Run automation checks
  await _runAutomationDemo();

  runApp(const KarnyBankApp());
}

/// Initialize sample data on first run
Future<void> _initializeSampleData() async {
  final existingAccounts = await DatabaseService.getAllAccounts();

  if (existingAccounts.isEmpty) {
    print('🏦 Initializing Karny Bank with sample accounts...');

    await DatabaseService.createAccount(
      name: 'Maayan',
      dateOfBirth: DateTime(2011, 8, 16),
    );

    await DatabaseService.createAccount(
      name: 'Tomer',
      dateOfBirth: DateTime(2014, 4, 28),
    );

    await DatabaseService.createAccount(
      name: 'Or',
      dateOfBirth: DateTime(2016, 1, 21),
    );

    print('✅ Accounts created successfully');
  }
}

/// Demo automation functions
Future<void> _runAutomationDemo() async {
  print('\n📊 Running automation checks...\n');

  // Run all automation checks
  final result = await AutomationService.runAllAutomationChecks();

  if (result.success) {
    print('✅ Automation checks completed successfully\n');
    print('Allowance: ${result.allowanceResult.message}');
    if (result.allowanceResult.processedAccounts.isNotEmpty) {
      for (final record in result.allowanceResult.processedAccounts) {
        print('  └─ ${record.toString()}');
      }
    }

    print('\nInterest: ${result.interestResult.message}');
    if (result.interestResult.processedAccounts.isNotEmpty) {
      for (final record in result.interestResult.processedAccounts) {
        print('  └─ ${record.toString()}');
      }
    }

    print('\nBonuses:');
    for (int q = 1; q <= 4; q++) {
      final bonusResult = result.bonusResults[q]!;
      print('  Q$q: ${bonusResult.message}');
      if (bonusResult.processedAccounts.isNotEmpty) {
        for (final record in bonusResult.processedAccounts) {
          print('    └─ ${record.toString()}');
        }
      }
      if (bonusResult.skippedAccounts.isNotEmpty) {
        for (final record in bonusResult.skippedAccounts) {
          print('    ⊘ ${record.toString()}');
        }
      }
    }
  } else {
    print('❌ Automation error: ${result.error}');
  }
}

class KarnyBankApp extends StatelessWidget {
  const KarnyBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karny Bank',
      theme: ThemeData(
        primaryColor: const Color(0xFF4DB6AC),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

/// Main dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<AccountSummary> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final summaries = await DatabaseService.getAllAccountSummaries();
    setState(() {
      accounts = summaries;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karny Bank'),
        backgroundColor: const Color(0xFF4DB6AC),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDepositDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Deposit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF81C784),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showWithdrawalDialog(),
                            icon: const Icon(Icons.remove),
                            label: const Text('Withdraw'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB74D),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Account cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return _buildAccountCard(account);
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
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

  Widget _buildAccountCard(AccountSummary account) {
    final balance = account.currentBalanceAgorot / 100;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(account.name[0]),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Age ${account.getAge()}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₪${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4DB6AC),
              ),
            ),
            const SizedBox(height: 12),
            if (account.lastDepositDate != null)
              Text(
                'Last Deposit: ₪${(account.lastDepositAmount ?? 0) / 100} '
                '(${account.lastDepositDate})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (account.lastWithdrawalDate != null)
              Text(
                'Last Withdrawal: ₪${(account.lastWithdrawalAmount ?? 0) / 100} '
                '(${account.lastWithdrawalDate})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => _TransactionDialog(
        title: 'Deposit Money',
        accounts: accounts,
        onSubmit: (accountId, amount) async {
          try {
            await TransactionService.addManualDeposit(
              accountId: accountId,
              amountAgorot: (double.parse(amount) * 100).toInt(),
            );
            await _loadAccounts();
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deposit successful!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (context) => _TransactionDialog(
        title: 'Withdraw Money',
        accounts: accounts,
        onSubmit: (accountId, amount) async {
          try {
            await TransactionService.addManualWithdrawal(
              accountId: accountId,
              amountAgorot: (double.parse(amount) * 100).toInt(),
            );
            await _loadAccounts();
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdrawal successful!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

/// Reusable transaction dialog
class _TransactionDialog extends StatefulWidget {
  final String title;
  final List<AccountSummary> accounts;
  final Function(int accountId, String amount) onSubmit;

  const _TransactionDialog({
    required this.title,
    required this.accounts,
    required this.onSubmit,
  });

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  int? selectedAccountId;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            hint: const Text('Select Account'),
            value: selectedAccountId,
            isExpanded: true,
            items: widget.accounts
                .map((account) => DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedAccountId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ILS)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedAccountId != null && amountController.text.isNotEmpty
              ? () => widget.onSubmit(
                    selectedAccountId!,
                    amountController.text,
                  )
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
