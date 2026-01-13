// lib/widgets/calculator_widget.dart
// Quick calculator overlay for parent

import 'package:flutter/material.dart';
import '../constants/theme.dart';

class CalculatorWidget extends StatefulWidget {
  final VoidCallback onClose;

  const CalculatorWidget({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '0';
  double? _firstNumber;
  String? _operation;
  bool _shouldResetDisplay = false;

  void _appendNumber(String number) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
    });
  }

  void _appendDecimal() {
    if (!_display.contains('.')) {
      setState(() {
        _display += '.';
        _shouldResetDisplay = false;
      });
    }
  }

  void _setOperation(String op) {
    if (_firstNumber == null) {
      _firstNumber = double.tryParse(_display);
    } else if (!_shouldResetDisplay) {
      _calculate();
      _firstNumber = double.tryParse(_display);
    }
    setState(() {
      _operation = op;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_firstNumber == null || _operation == null) return;

    final secondNumber = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber! + secondNumber;
        break;
      case '-':
        result = _firstNumber! - secondNumber;
        break;
      case '×':
        result = _firstNumber! * secondNumber;
        break;
      case '÷':
        result = secondNumber != 0 ? _firstNumber! / secondNumber : 0;
        break;
    }

    setState(() {
      _display = result.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      _firstNumber = null;
      _operation = null;
      _shouldResetDisplay = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstNumber = null;
      _operation = null;
      _shouldResetDisplay = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  Widget _buildButton(
    String label, {
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? KarnyColors.grey,
            foregroundColor: textColor ?? KarnyColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KarnyRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(KarnySpacing.md),
        decoration: BoxDecoration(
          color: KarnyColors.white,
          borderRadius: BorderRadius.circular(KarnyRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calculator',
                  style: TextStyle(
                    fontSize: KarnyFontSize.lg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: KarnySpacing.md),
            // Display
            Container(
              padding: const EdgeInsets.all(KarnySpacing.md),
              decoration: BoxDecoration(
                color: KarnyColors.background,
                borderRadius: BorderRadius.circular(KarnyRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _display,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: KarnyColors.primary,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KarnySpacing.md),
            // Buttons
            Row(
              children: [
                _buildButton('C', onPressed: _clear, backgroundColor: KarnyColors.error),
                _buildButton('←', onPressed: _backspace),
                _buildButton('÷', onPressed: () => _setOperation('÷'), backgroundColor: KarnyColors.warning),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildButton('7', onPressed: () => _appendNumber('7')),
                _buildButton('8', onPressed: () => _appendNumber('8')),
                _buildButton('9', onPressed: () => _appendNumber('9')),
                _buildButton('×', onPressed: () => _setOperation('×'), backgroundColor: KarnyColors.warning),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildButton('4', onPressed: () => _appendNumber('4')),
                _buildButton('5', onPressed: () => _appendNumber('5')),
                _buildButton('6', onPressed: () => _appendNumber('6')),
                _buildButton('-', onPressed: () => _setOperation('-'), backgroundColor: KarnyColors.warning),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildButton('1', onPressed: () => _appendNumber('1')),
                _buildButton('2', onPressed: () => _appendNumber('2')),
                _buildButton('3', onPressed: () => _appendNumber('3')),
                _buildButton('+', onPressed: () => _setOperation('+'), backgroundColor: KarnyColors.warning),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildButton('0', onPressed: () => _appendNumber('0')),
                _buildButton('.', onPressed: _appendDecimal),
                const SizedBox.expand(),
                _buildButton('=', onPressed: _calculate, backgroundColor: KarnyColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
