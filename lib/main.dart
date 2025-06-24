import 'package:flutter/material.dart';
import 'auth/splash_screen.dart';

void main() {
  runApp(MukBitesApp());
}

class MukBitesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Load splash screen here
    );
  }
}

