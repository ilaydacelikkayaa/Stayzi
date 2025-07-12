import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/search/date_time_picker.dart';

class TakvimBilgisi extends StatefulWidget {
  final Function(DateTimeRange?)? onDateRangeChanged;
  const TakvimBilgisi({super.key, this.onDateRangeChanged});

  @override
  State<TakvimBilgisi> createState() => _TakvimBilgisiState();
}

class _TakvimBilgisiState extends State<TakvimBilgisi> {
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: DateRangePickerWidget(
              initialDateRange: selectedRange,
              onDateRangeChanged: (range) {
                setState(() {
                  selectedRange = range;
                });
                print('Başlangıç: ${range?.start}, Bitiş: ${range?.end}');
                widget.onDateRangeChanged?.call(range);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
