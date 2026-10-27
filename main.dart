import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vpn_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/logs_screen.dart';

class XnotColors {
  static const bg = Color(0xFF06080D);
  static const card = Color(0xFF0D1119);
  static const card2 = Color(0xFF121824);
  static const cyan = Color(0xFF19E6FF);
  static const purple = Color(0xFF8B5CFF);
  static const green = Color(0xFF35E38B);
  static const red = Color(0xFFFF5577);
  static const text = Color(0xFFF4F7FB);
  static const muted = Color(0xFF8D98AA);
}

void main() => runApp(const XnotApp());

class XnotApp extends StatelessWidget {
  const XnotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VpnProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Xnot VPN',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: XnotColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: XnotColors.cyan,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: XnotColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        routes: {
          '/': (_) => const HomeScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/logs': (_) => const LogsScreen(),
        },
      ),
    );
  }
}
