import 'package:flutter/material.dart';

class EventModel {
  final String title;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final bool isAllDay;

  const EventModel({
    required this.title,
    required this.from,
    required this.to,
    required this.backgroundColor,
    required this.isAllDay,
  });
}
