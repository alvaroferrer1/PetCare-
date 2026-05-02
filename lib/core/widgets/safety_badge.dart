import 'package:flutter/material.dart';

import '../../models/food_safety_item_model.dart';

class SafetyBadge extends StatelessWidget {
  const SafetyBadge({required this.level, super.key});

  final FoodSafetyLevel level;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (level) {
      FoodSafetyLevel.safe => (Colors.green, Icons.check_circle),
      FoodSafetyLevel.caution => (Colors.orange, Icons.warning_amber),
      FoodSafetyLevel.toxic => (Colors.red, Icons.dangerous),
      FoodSafetyLevel.unknown => (Colors.grey, Icons.help_outline),
    };

    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      backgroundColor: color.withValues(alpha: 0.13),
      label: Text(
        level.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.22)),
    );
  }
}
