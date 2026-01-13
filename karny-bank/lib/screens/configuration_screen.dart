// lib/screens/configuration_screen.dart
// Settings and configuration screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../providers/database_provider.dart';
import '../services/database_service.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  late TextEditingController _interestRateController;
  late TextEditingController _bonusRateController;
  int? _allowanceDay;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _interestRateController = TextEditingController();
    _bonusRateController = TextEditingController();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    final config = await DatabaseService.getConfiguration();
    setState(() {
      _interestRateController.text = config.getInterestRateAsPercent().toString();
      _bonusRateController.text = config.getBonusRateAsPercent().toString();
      _allowanceDay = config.weeklyAllowanceDay;
    });
  }

  @override
  void dispose() {
    _interestRateController.dispose();
    _bonusRateController.dispose();
    super.dispose();
  }

  void _markChanged() {
    setState(() => _hasChanges = true);
  }

  Future<void> _saveConfiguration() async {
    setState(() => _isLoading = true);

    try {
      // Validate inputs
      final interestRate = double.tryParse(_interestRateController.text);
      final bonusRate = double.tryParse(_bonusRateController.text);

      if (interestRate == null || bonusRate == null || _allowanceDay == null) {
        throw Exception('Please fill all fields');
      }

      if (interestRate < 0 || interestRate > 100) {
        throw Exception('Interest rate must be between 0 and 100');
      }

      if (bonusRate < 0 || bonusRate > 100) {
        throw Exception('Bonus rate must be between 0 and 100');
      }

      // Convert to storage format (multiply by 100 to store as integer)
      await DatabaseService.updateConfigValue(
        'annual_interest_rate',
        (interestRate * 100).toInt().toString(),
      );
      await DatabaseService.updateConfigValue(
        'quarterly_bonus_rate',
        (bonusRate * 100).toInt().toString(),
      );
      await DatabaseService.updateConfigValue(
        'weekly_allowance_day',
        _allowanceDay.toString(),
      );

      // Refresh all data
      refreshAllData(ref);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(configurationProvider);

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text(
                    'You have unsaved changes. Are you sure you want to leave?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings & Configuration'),
          backgroundColor: KarnyColors.primary,
          elevation: 0,
        ),
        body: config.when(
          data: (configuration) => SingleChildScrollView(
            child: Column(
              children: [
                // Warning Box
                Container(
                  margin: const EdgeInsets.all(KarnySpacing.lg),
                  padding: const EdgeInsets.all(KarnySpacing.md),
                  decoration: BoxDecoration(
                    color: KarnyColors.warning.withOpacity(0.1),
                    border: Border.all(color: KarnyColors.warning),
                    borderRadius: BorderRadius.circular(KarnyRadius.md),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: KarnyColors.warning,
                        ),
                      ),
                      SizedBox(height: KarnySpacing.sm),
                      Text(
                        'All changes will take effect immediately for all future transactions. Past balances and transactions are locked.',
                        style: TextStyle(
                          fontSize: KarnyFontSize.sm,
                          color: KarnyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Configuration Fields
                Padding(
                  padding: const EdgeInsets.all(KarnySpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Rates Section
                      const Text(
                        'Financial Rates',
                        style: TextStyle(
                          fontSize: KarnyFontSize.lg,
                          fontWeight: FontWeight.bold,
                          color: KarnyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: KarnySpacing.md),

                      // Interest Rate
                      TextField(
                        controller: _interestRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _markChanged(),
                        decoration: InputDecoration(
                          labelText: 'Annual Interest Rate (%)',
                          hintText: '2.8',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KarnyRadius.md),
                          ),
                        ),
                      ),
                      const SizedBox(height: KarnySpacing.sm),
                      const Text(
                        'Applied annually on January 1st',
                        style: TextStyle(
                          fontSize: KarnyFontSize.xs,
                          color: KarnyColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: KarnySpacing.md),

                      // Bonus Rate
                      TextField(
                        controller: _bonusRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _markChanged(),
                        decoration: InputDecoration(
                          labelText: 'Quarterly Bonus Rate (%)',
                          hintText: '1.2',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KarnyRadius.md),
                          ),
                        ),
                      ),
                      const SizedBox(height: KarnySpacing.sm),
                      const Text(
                        'Applied quarterly only if there are ZERO withdrawals in that quarter',
                        style: TextStyle(
                          fontSize: KarnyFontSize.xs,
                          color: KarnyColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: KarnySpacing.xxl),

                      // Allowance Schedule Section
                      const Text(
                        'Allowance Schedule',
                        style: TextStyle(
                          fontSize: KarnyFontSize.lg,
                          fontWeight: FontWeight.bold,
                          color: KarnyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: KarnySpacing.md),

                      // Allowance Day
                      DropdownButtonFormField<int>(
                        value: _allowanceDay,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Sunday')),
                          DropdownMenuItem(value: 1, child: Text('Monday')),
                          DropdownMenuItem(value: 2, child: Text('Tuesday')),
                          DropdownMenuItem(value: 3, child: Text('Wednesday')),
                          DropdownMenuItem(value: 4, child: Text('Thursday')),
                          DropdownMenuItem(value: 5, child: Text('Friday')),
                          DropdownMenuItem(value: 6, child: Text('Saturday')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _allowanceDay = value;
                              _markChanged();
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Weekly Allowance Day',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KarnyRadius.md),
                          ),
                        ),
                      ),
                      const SizedBox(height: KarnySpacing.sm),
                      const Text(
                        'Allowance equals child\'s age, updated automatically on their birthday',
                        style: TextStyle(
                          fontSize: KarnyFontSize.xs,
                          color: KarnyColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: KarnySpacing.xxl),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || !_hasChanges ? null : _saveConfiguration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KarnyColors.success,
                            foregroundColor: KarnyColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: KarnySpacing.md,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      KarnyColors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
