import 'dart:ui';

// ignore: unused_import
import 'package:you_tour_app/screens/models/setting_item.dart';

class SettingItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  SettingItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class IconData {}
