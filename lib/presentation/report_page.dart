import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../core/fa.dart';
import '../core/money.dart';
import '../domain/category.dart';
import 'widgets/jalali_month_picker.dart';

/// تبِ «گزارش»: انتخابگرِ ماهِ شمسی + کارت‌های خلاصه + نمودارِ دایره‌ایِ هزینه (تمایزِ محصول).
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedReportMonthProvider);
    final totalsAsync = ref.watch(monthlyTotalsProvider(month));
    final spendingAsync = ref.watch(categorySpendingProvider(month));

    return Scaffold(
      appBar: AppBar(title: const Text('گزارش')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const JalaliMonthPicker(),
          const SizedBox(height: 16),
          totalsAsync.when(
            loading: () => const _LoadingBox(),
            error: (e, _) => Text('خطا: $e'),
            data: (t) => _SummaryCards(
              income: Money(t.incomeRial),
              expense: Money(t.expenseRial),
            ),
          ),
          const SizedBox(height: 24),
          Text('تفکیکِ هزینه', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          spendingAsync.when(
            loading: () => const _LoadingBox(),
            error: (e, _) => Text('خطا: $e'),
            data: (slices) => _ExpensePie(slices: slices),
          ),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.income, required this.expense});
  final Money income;
  final Money expense;

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'درآمد', money: income, color: Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'هزینه', money: expense, color: Colors.red)),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'مانده',
            money: balance,
            color: balance.isNegative ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.money, required this.color});
  final String label;
  final Money money;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(
                formatToman(money),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _pieColors = <Color>[
  Color(0xFF1E8E6E), Color(0xFFE0662B), Color(0xFF3B6FB6), Color(0xFFB63B6F),
  Color(0xFFB69B3B), Color(0xFF6E3BB6), Color(0xFF3BB6A0), Color(0xFF888888),
];

class _ExpensePie extends StatelessWidget {
  const _ExpensePie({required this.slices});
  final List<CategorySlice> slices;

  @override
  Widget build(BuildContext context) {
    final nonZero = slices.where((s) => s.totalRial > 0).toList();
    if (nonZero.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('هزینه‌ای در این ماه ثبت نشده')),
      );
    }
    final total = nonZero.fold<int>(0, (a, s) => a + s.totalRial);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: [
                for (var i = 0; i < nonZero.length; i++)
                  PieChartSectionData(
                    value: nonZero[i].totalRial.toDouble(),
                    color: _pieColors[i % _pieColors.length],
                    radius: 60,
                    title: '${toFaDigits(((nonZero[i].totalRial / total) * 100).round().toString())}٪',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < nonZero.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _pieColors[i % _pieColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${nonZero[i].name}  ${formatToman(nonZero[i].total)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
