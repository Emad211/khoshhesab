import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../core/money.dart';
import '../domain/category.dart';
import '../domain/transaction.dart';
import 'widgets/category_chips.dart';
import 'widgets/jalali_date_field.dart';

/// ثبتِ سریعِ تراکنش — نوع + مبلغ + تاریخِ شمسی + دسته (PRODUCT_BRIEF: کمتر از ۳ ثانیه).
class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _amountCtrl = TextEditingController();
  TxKind _kind = TxKind.expense;
  Category? _category;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
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
    final tx = Tx(
      amount: Money.fromToman(toman),
      kind: _kind,
      categoryId: _category?.id,
      category: _category?.name, // snapshotِ نمایش
      occurredAt: _date,
    );
    await ref.read(transactionRepositoryProvider).add(tx);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبتِ تراکنش')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
            onSelectionChanged: (s) => setState(() {
              _kind = s.first;
              _category = null; // دسته‌ها وابسته به نوع‌اند
            }),
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
          JalaliDateField(
            value: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
          const SizedBox(height: 16),
          const Text('دسته', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CategoryChips(
            kind: _kind,
            selectedId: _category?.id,
            onSelected: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}
