// lib/widgets/financial_tips_dialog.dart
// Financial tips popup after deposits

import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/theme.dart';
import '../services/database_service.dart';
import '../services/database_models.dart';

// Financial tips database
const Map<String, List<String>> financialTips = {
  // Ages 7-10 (Or)
  'junior': [
    'Your money loves to have friends! Every ILS you save today invites more ILS to join it tomorrow.',
    'Saving is like planting a seed. It might look small now, but wait a few weeks, and you\'ll have a whole money tree!',
    'Did you know? The more you save, the bigger the quarterly bonus from Karny Bank! It\'s our way of saying, \'Nice job!\'',
    'Saving money is like having a superpower. Instead of flying, you can buy awesome stuff later without begging!',
    'Before you buy something, ask your money: "Do you need to leave me?" Sometimes, the answer is \'No!\'',
  ],
  // Ages 10-13 (Tomer)
  'intermediate': [
    'Patience is Profit: Waiting three days before buying something you want is a super-test. If you still want it, buy it. If not, you just saved money!',
    'Think of big purchases like boss battles in a video game. You need to gather gold (ILS) and level up your savings before you can win!',
    'Don\'t spend your money just because it\'s there. That\'s like eating all your snacks on Monday—what about Friday?!',
    'Budgeting is simple: Income is what you get. Expenses is where it goes. Save is what makes you rich!',
    'When you buy cheap things repeatedly, it costs more than buying one high-quality thing. Buy nice, not twice!',
  ],
  // Ages 13+ (Maayan)
  'advanced': [
    'Congrats! The money you just saved is now working for you, earning interest while you sleep. Free money is the best kind of money!',
    'An Opportunity Cost is what you give up when you choose one thing over another. Choosing that small candy means giving up part of that cool book later. Choose wisely!',
    'Treat your savings account like a VIP room. Only the most important goals get to take money out of it.',
    'Want to be rich? It\'s not about how much you make, it\'s about how much you keep. Keep more than you spend!',
    'You are receiving 2.8% interest! That might seem small, but even tiny seeds grow big trees. Let time be your friend.',
  ],
};

String _getTipCategory(int age) {
  if (age <= 10) return 'junior';
  if (age <= 13) return 'intermediate';
  return 'advanced';
}

String _getRandomTip(int age) {
  final category = _getTipCategory(age);
  final tips = financialTips[category] ?? [];
  return tips[Random().nextInt(tips.length)];
}

void showFinancialTipDialog(BuildContext context, int accountId) async {
  try {
    final account = await DatabaseService.getAccountById(accountId);
    if (account == null) return;

    final tip = _getRandomTip(account.getAge());

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _FinancialTipDialog(
        tip: tip,
        accountName: account.name,
        age: account.getAge(),
      ),
    );
  } catch (e) {
    debugPrint('Error showing financial tip: $e');
  }
}

class _FinancialTipDialog extends StatefulWidget {
  final String tip;
  final String accountName;
  final int age;

  const _FinancialTipDialog({
    required this.tip,
    required this.accountName,
    required this.age,
  });

  @override
  State<_FinancialTipDialog> createState() => _FinancialTipDialogState();
}

class _FinancialTipDialogState extends State<_FinancialTipDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Auto-close after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTipColor() {
    if (widget.age <= 10) return KarnyColors.success;
    if (widget.age <= 13) return KarnyColors.info;
    return KarnyColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KarnyRadius.lg),
          ),
          child: Container(
            padding: const EdgeInsets.all(KarnySpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KarnyRadius.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getTipColor().withOpacity(0.1),
                  _getTipColor().withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lightbulb icon
                Container(
                  padding: const EdgeInsets.all(KarnySpacing.md),
                  decoration: BoxDecoration(
                    color: _getTipColor(),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: KarnyColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: KarnySpacing.md),
                // Tip title
                Text(
                  '💡 Quick Tip for ${widget.accountName}!',
                  style: const TextStyle(
                    fontSize: KarnyFontSize.lg,
                    fontWeight: FontWeight.bold,
                    color: KarnyColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KarnySpacing.md),
                // Tip content
                Text(
                  widget.tip,
                  style: const TextStyle(
                    fontSize: KarnyFontSize.md,
                    color: KarnyColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KarnySpacing.lg),
                // Close button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it! 👍'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
