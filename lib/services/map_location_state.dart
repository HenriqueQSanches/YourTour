import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapLocationState {
  MapLocationState._();

  static const LatLng _defaultCenter = LatLng(-23.6204, -46.5616);
  static const String _defaultLabel =
      'Rua Santo Antônio - São Caetano do Sul';

  static final ValueNotifier<LatLng> currentCenter =
      ValueNotifier<LatLng>(_defaultCenter);

  static final ValueNotifier<String> currentLabel =
      ValueNotifier<String>(_defaultLabel);

  static Future<void> init() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final double? lat = prefs.getDouble('last_location_lat');
      final double? lon = prefs.getDouble('last_location_lon');
      final String? label = prefs.getString('last_location_label');
      if (lat != null && lon != null) {
        currentCenter.value = LatLng(lat, lon);
      }
      if (label != null && label.isNotEmpty) {
        currentLabel.value = label;
      }
    } catch (_) {}
  }

  static Future<void> setLocation(LatLng center, String label) async {
    currentCenter.value = center;
    currentLabel.value = label;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_location_lat', center.latitude);
      await prefs.setDouble('last_location_lon', center.longitude);
      await prefs.setString('last_location_label', label);
    } catch (_) {}
  }
}

