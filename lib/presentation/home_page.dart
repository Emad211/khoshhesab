import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import '../core/fa.dart';
import '../core/money.dart';
import '../domain/transaction.dart';
import 'add_transaction_page.dart';

/// صفحهٔ اصلی: ماندهٔ کل + لیستِ تراکنش‌ها + دکمهٔ ثبت (walking skeleton).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);
    final balance = ref.watch(balanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('خوش‌حساب')),
      body: Column(
        children: [
          _BalanceCard(balance: balance),
          const Divider(height: 1),
          Expanded(
            child: txsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (txs) => txs.isEmpty
                  ? const Center(child: Text('هنوز تراکنشی ثبت نشده'))
                  : ListView.separated(
                      itemCount: txs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _TxTile(tx: txs[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('ثبت'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final Money balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'ماندهٔ کل',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            formatToman(balance),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: balance.isNegative ? Colors.red : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});
  final Tx tx;

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.kind == TxKind.expense;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
        child: Icon(
          isExpense ? Icons.south_west : Icons.north_east,
          color: isExpense ? Colors.red : Colors.green,
        ),
      ),
      title: Text(tx.category ?? (isExpense ? 'هزینه' : 'درآمد')),
      subtitle: Text(formatJalali(tx.occurredAt)),
      trailing: Text(
        formatToman(tx.amount),
        style: TextStyle(
          color: isExpense ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
