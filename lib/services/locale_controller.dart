import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const String _prefsKey = 'app_locale_code';
  static final ValueNotifier<Locale> current =
      ValueNotifier<Locale>(const Locale('pt', 'BR'));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      current.value = _localeFromCode(code);
    }
  }

  static Future<void> setLocaleCode(String code) async {
    final locale = _localeFromCode(code);
    current.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }

  static Locale _localeFromCode(String code) {
    switch (code) {
      case 'en':
      case 'en_US':
        return const Locale('en', 'US');
      case 'es':
        return const Locale('es');
      case 'fr':
        return const Locale('fr');
      case 'de':
        return const Locale('de');
      case 'it':
        return const Locale('it');
      case 'ja':
        return const Locale('ja');
      case 'zh':
        return const Locale('zh');
      case 'ar':
        return const Locale('ar');
      case 'ru':
        return const Locale('ru');
      case 'pt':
      case 'pt_BR':
      default:
        return const Locale('pt', 'BR');
    }
  }
}


