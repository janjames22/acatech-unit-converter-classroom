import 'package:flutter/material.dart';

IconData iconForCategory(String categoryId) => switch (categoryId) {
  'length' => Icons.straighten_rounded,
  'area' => Icons.aspect_ratio_rounded,
  'mass' => Icons.scale_rounded,
  'temperature' => Icons.thermostat_rounded,
  'speed' => Icons.speed_rounded,
  'volume' => Icons.local_drink_rounded,
  'time' => Icons.schedule_rounded,
  'digital_storage' => Icons.storage_rounded,
  'pressure' => Icons.compress_rounded,
  _ => Icons.calculate_rounded,
};
