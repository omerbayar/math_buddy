import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localization.dart';

/// Global dil bildiricisi — theme_controller.dart deseniyle paralel.
final ValueNotifier<Locale> appLocale =
    ValueNotifier<Locale>(const Locale('en'));

/// Desteklenen diller: dil kodu → (görünen ad, bayrak emojisi)
const Map<String, (String, String)> supportedLanguages = {
  'en': ('English',  '🇬🇧'),
  'tr': ('Türkçe',   '🇹🇷'),
  'de': ('Deutsch',  '🇩🇪'),
  'ro': ('Română',   '🇷🇴'),
  'fr': ('Français', '🇫🇷'),
  'it': ('Italiano', '🇮🇹'),
  'es': ('Español',  '🇪🇸'),
  'ru': ('Русский',  '🇷🇺'),
};

/// Kaydedilen dili shared_preferences'tan yükler; yoksa 'en' kullanır.
/// main() içinde runApp'tan önce çağrılmalı.
Future<void> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('language') ?? 'en';
  final locale = Locale(lang);
  await AppLocalization(locale).load();
  appLocale.value = locale;
}

/// Dili değiştirir: JSON'u singleton'a yükler, prefs'e kaydeder,
/// ardından appLocale'ı günceller → MaterialApp rebuild olur.
Future<void> setLocale(String code) async {
  final locale = Locale(code);
  await AppLocalization(locale).load();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', code);
  appLocale.value = locale;
}
