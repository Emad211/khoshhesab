import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../core/money.dart';
import '../domain/transaction.dart';

/// ثبتِ سریعِ تراکنش — هدفِ تجربه: کمتر از ۳ ثانیه (PRODUCT_BRIEF).
class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  TxKind _kind = TxKind.expense;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final toman = int.tryParse(_amountCtrl.text.trim());
    if (toman == null || toman <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ را به تومان وارد کنید')),
      );
      return;
    }
    final category = _categoryCtrl.text.trim();
    final tx = Tx(
      amount: Money.fromToman(toman),
      kind: _kind,
      category: category.isEmpty ? null : category,
      occurredAt: DateTime.now(),
    );
    await ref.read(transactionRepositoryProvider).add(tx);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبتِ تراکنش')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TxKind>(
              segments: const [
                ButtonSegment(
                  value: TxKind.expense,
                  label: Text('هزینه'),
                  icon: Icon(Icons.south_west),
                ),
                ButtonSegment(
                  value: TxKind.income,
                  label: Text('درآمد'),
                  icon: Icon(Icons.north_east),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'مبلغ (تومان)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'دسته (اختیاری)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
