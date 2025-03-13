import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(55, 24, 26, 95),
      body:
          Center(child: Image.asset('assets/images/Ipslink_splashscreen.png')),
    );
  }
}
