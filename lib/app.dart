import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'shared/nav_shell.dart';

class MathBuddyApp extends StatelessWidget {
  const MathBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        // Efektif parlaklığı hesapla
        final platformBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final effectiveBrightness = switch (mode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => platformBrightness,
        };

        // AppColors getter'larının doğru değer döndürmesi için güncelle
        AppColors.setBrightness(effectiveBrightness);

        return MaterialApp(
          title: 'Math Buddy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const NavShell(),
        );
      },
    );
  }
}
