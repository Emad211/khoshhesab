import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/fa.dart';

/// فیلدِ انتخابِ تاریخِ شمسی (بدونِ وابستگیِ بیرونی): دیالوگِ سه‌منتخابیِ روز/ماه/سال.
class JalaliDateField extends StatelessWidget {
  const JalaliDateField({super.key, required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDialog<DateTime>(
          context: context,
          builder: (_) => _JalaliPickerDialog(initial: value),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاریخ',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(formatJalali(value)),
      ),
    );
  }
}

class _JalaliPickerDialog extends StatefulWidget {
  const _JalaliPickerDialog({required this.initial});
  final DateTime initial;

  @override
  State<_JalaliPickerDialog> createState() => _JalaliPickerDialogState();
}

class _JalaliPickerDialogState extends State<_JalaliPickerDialog> {
  late int _year;
  late int _month;
  late int _day;

  static const _months = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  @override
  void initState() {
    super.initState();
    final j = Jalali.fromDateTime(widget.initial);
    _year = j.year;
    _month = j.month;
    _day = j.day;
  }

  int get _maxDay => Jalali(_year, _month, 1).monthLength;

  @override
  Widget build(BuildContext context) {
    final nowYear = Jalali.now().year;
    final years = [for (var y = nowYear - 10; y <= nowYear + 1; y++) y];
    if (_day > _maxDay) _day = _maxDay;

    return AlertDialog(
      title: const Text('انتخابِ تاریخ'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: _day,
              isExpanded: true,
              items: [
                for (var d = 1; d <= _maxDay; d++)
                  DropdownMenuItem(value: d, child: Text(toFaDigits('$d'))),
              ],
              onChanged: (v) => setState(() => _day = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButton<int>(
              value: _month,
              isExpanded: true,
              items: [
                for (var m = 1; m <= 12; m++)
                  DropdownMenuItem(value: m, child: Text(_months[m - 1])),
              ],
              onChanged: (v) => setState(() => _month = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: _year,
              isExpanded: true,
              items: [
                for (final y in years)
                  DropdownMenuItem(value: y, child: Text(toFaDigits('$y'))),
              ],
              onChanged: (v) => setState(() => _year = v!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () {
            final g = Jalali(_year, _month, _day).toGregorian();
            final now = DateTime.now();
            Navigator.pop(
              context,
              DateTime(g.year, g.month, g.day, now.hour, now.minute, now.second),
            );
          },
          child: const Text('تأیید'),
        ),
      ],
    );
  }
}
