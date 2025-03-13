import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/splashscreen.dart';
import 'firebase/firebase.dart';

void main() async {
  await FireBase.start();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  Manager? manager;
  @override
  void initState() {
    manager = Manager(navigatorKey: navKey);
    super.initState();
  }

  @override
  void dispose() {
    manager!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    manager!.setContext(context: context);

    return MaterialApp(
      title: 'Ipslink',
      home: const SplashScreen(),
      navigatorKey: navKey,
    );
  }
}
