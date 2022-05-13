import 'dart:developer';

import 'package:calendar/Model/event_model.dart';
import 'package:calendar/Provider/event_provider.dart';
import 'package:calendar/Screen/calendarpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvent = provider.eventsOfSelectedDate;
    if (selectedEvent.isEmpty) {
      return const Center(
        child: Text(
          'No Events found!',
          style: TextStyle(color: Colors.black, fontSize: 24.0),
        ),
      );
    }

    return SfCalendarTheme(
      data: SfCalendarThemeData(),
      child: SfCalendar(
        view: CalendarView.schedule,
        dataSource: EventDataSource(provider.events),
        initialDisplayDate: provider.selectedDate,
        appointmentBuilder: appointmentBuilder,
      ),
    );
  }

  Widget appointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    EventModel event = details.appointments.first;
    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
          color: event.backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
