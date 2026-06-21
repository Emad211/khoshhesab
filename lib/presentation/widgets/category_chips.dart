import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/category.dart';
import '../../domain/transaction.dart' show TxKind;

/// انتخابگرِ تک‌گزینه‌ایِ دسته با ChoiceChip، فیلترشده بر نوعِ تراکنش.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({
    super.key,
    required this.kind,
    required this.selectedId,
    required this.onSelected,
  });

  final TxKind kind;
  final int? selectedId;
  final ValueChanged<Category?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider(kind));
    return cats.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('خطا: $e'),
      data: (list) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in list)
            ChoiceChip(
              label: Text(c.name),
              selected: selectedId == c.id,
              onSelected: (_) => onSelected(selectedId == c.id ? null : c),
            ),
        ],
      ),
    );
  }
}
