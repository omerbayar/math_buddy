import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'shared/nav_shell.dart';

class MathBuddyApp extends StatelessWidget {
  const MathBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const NavShell(),
    );
  }
}
