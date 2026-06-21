import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../presentation/main_shell.dart';

/// ریشهٔ اپ: RTL کامل + locale فارسی + تمِ Material 3 (ADR-0005).
class KhoshHesabApp extends StatelessWidget {
  const KhoshHesabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خوش‌حساب',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E8E6E),
        brightness: Brightness.light,
      ),
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}
