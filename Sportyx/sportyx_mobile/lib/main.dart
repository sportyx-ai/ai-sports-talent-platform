import 'package:flutter/material.dart';
import 'core/api_config.dart';
import 'features/home/home_page.dart';
import 'features/home/landing_page.dart';
import 'features/home/events_page.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asynchronously probe backend server candidates on startup
  ApiConfig.autoDetectServer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sportyx",
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/events': (context) => const EventsPage(),
      },
    );
  }
}