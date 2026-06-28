import 'package:flutter/material.dart';

/// Global tema modu bildiricisi.
/// system → light → dark → system döngüsüyle döner.
final ValueNotifier<ThemeMode> appThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.system);

void cycleThemeMode() {
  switch (appThemeMode.value) {
    case ThemeMode.system:
      appThemeMode.value = ThemeMode.light;
    case ThemeMode.light:
      appThemeMode.value = ThemeMode.dark;
    case ThemeMode.dark:
      appThemeMode.value = ThemeMode.system;
  }
}
