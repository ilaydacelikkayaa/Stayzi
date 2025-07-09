import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TakvimBilgisi extends StatelessWidget {
  const TakvimBilgisi({super.key});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 365)),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Ay',
        CalendarFormat.twoWeeks: '2 Hafta',
        CalendarFormat.week: 'Hafta',
      },
      selectedDayPredicate: (day) {
        // Seçili gün kontrolü — istersen burada kendi mantığını kur
        return false;
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(formatButtonVisible: true, titleCentered: true),
      onDaySelected: (selectedDay, focusedDay) {
        // Bir gün seçildiğinde yapılacaklar
        print('Seçilen gün: $selectedDay');
      },
    );
  }
}
