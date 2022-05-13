import 'dart:collection';
import 'dart:developer';

import 'package:calendar/Model/event_model.dart';
import 'package:calendar/Provider/event_provider.dart';
import 'package:calendar/Widgets/taskwidget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  final EventModel? eventModel;
  const CalendarPage({Key? key, this.eventModel}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  late List<Calendar> _calendars;
  late List<Event> calEventsList;
  @override
  initState() {
    super.initState();
    calEventsList = [];
    _retrieveCalendars();
    Provider.of<EventProvider>(context, listen: false).events;
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess) {
          return;
        }
      }

      final startDate = DateTime.now();
      final endDate = DateTime.now().add(const Duration(days: 360));

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      _calendars = calendarsResult.data!;
      for (int i = 0; i < _calendars.length; i++) {
        final calEvents = await _deviceCalendarPlugin.retrieveEvents(
            _calendars[i].id,
            RetrieveEventsParams(startDate: startDate, endDate: endDate));

        List<Event> singleCalendarEvents = calEvents.data as List<Event>;

        calEventsList.addAll(singleCalendarEvents);
      }

      setState(() {
        final provider = Provider.of<EventProvider>(context, listen: false);
        for (var chm in calEventsList) {
          DateTime start = DateTime.fromMillisecondsSinceEpoch(
              chm.start!.millisecondsSinceEpoch);
          DateTime end = DateTime.fromMillisecondsSinceEpoch(
              chm.end!.millisecondsSinceEpoch);
          final eves = EventModel(
              title: chm.title ?? 'empty',
              from: start,
              to: end,
              backgroundColor: Colors.red,
              isAllDay: chm.allDay ?? false);

          log("\n check Date -----*****${eves.from}");

          provider.addEvent(eves);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EventProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Calendar')),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        backgroundColor: Colors.white,
        //firstDayOfWeek: 6,
        initialSelectedDate: DateTime.now(),
        dataSource: EventDataSource(vm.events),
        onTap: (details) {
          final provider = Provider.of<EventProvider>(context, listen: false);
          provider.setDate(details.date!);

          showModalBottomSheet(
            context: context,
            builder: (context) => TaskWidget(),
          );
        },
      ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventModel> appointments) {
    this.appointments = appointments;
  }

  EventModel getEvent(int index) => appointments![index] as EventModel;

  @override
  DateTime getStartTime(int index) => getEvent(index).from;

  @override
  DateTime getEndTime(int index) => getEvent(index).to;

  String? getTitle(int index) => getEvent(index).title;
}
