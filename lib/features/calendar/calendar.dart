import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/manager.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidgetPage extends StatefulWidget {
  final Manager manager;

  CalendarWidgetPage({
    required this.manager,
  });

  @override
  State<CalendarWidgetPage> createState() => _CalendarWidgetPageState();
}

class _CalendarWidgetPageState extends State<CalendarWidgetPage> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        appBar: PageAppBar(manager: widget.manager),
        manager: widget.manager,
        body: CalendarWidget());
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2023, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }
}
