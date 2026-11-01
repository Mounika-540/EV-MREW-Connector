import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() => runApp(const EvApp());

class EvApp extends StatelessWidget {
  const EvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV-M+REW Connector',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
