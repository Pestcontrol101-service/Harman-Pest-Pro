import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('properties');
  await Hive.openBox('services');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harman Pest Pro',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
