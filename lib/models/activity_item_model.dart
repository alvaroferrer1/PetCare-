import 'package:flutter/material.dart';

class ActivityItemModel {
  const ActivityItemModel({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
}
