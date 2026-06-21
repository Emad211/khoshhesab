import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

/// نوارِ انتخابگرِ ماهِ شمسی (chevronهای RTL: راست=قبلی، چپ=بعدی).
class JalaliMonthPicker extends ConsumerWidget {
  const JalaliMonthPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedReportMonthProvider);
    final notifier = ref.read(selectedReportMonthProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'ماهِ قبل',
          onPressed: () => notifier.state = month.previous(),
        ),
        Text(
          month.label(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'ماهِ بعد',
          onPressed: () => notifier.state = month.next(),
        ),
      ],
    );
  }
}
