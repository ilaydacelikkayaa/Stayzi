import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateRangePickerWidget extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange?) onDateRangeChanged;

  const DateRangePickerWidget({
    super.key,
    this.initialDateRange,
    required this.onDateRangeChanged,
  });

  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDateRange?.start;
    _endDate = widget.initialDateRange?.end;
  }

  @override
  void didUpdateWidget(covariant DateRangePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDateRange != widget.initialDateRange) {
      setState(() {
        _startDate = widget.initialDateRange?.start;
        _endDate = widget.initialDateRange?.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: DateTime.now(),
      calendarFormat: _calendarFormat,
      rangeStartDay: _startDate,
      rangeEndDay: _endDate,
      rangeSelectionMode: _rangeSelectionMode,
      onRangeSelected: (start, end, _) {
        setState(() {
          _startDate = start;
          _endDate = end;
        });

        if (start != null && end != null) {
          widget.onDateRangeChanged(DateTimeRange(start: start, end: end));
        }
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      calendarStyle: CalendarStyle(
        rangeHighlightColor: Colors.grey.withOpacity(0.3),
        todayDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        withinRangeDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
    );
  }
}
