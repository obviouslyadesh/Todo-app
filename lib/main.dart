import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_todo_app/screens/home_screen.dart';
import 'package:my_todo_app/services/database.dart';
import 'package:my_todo_app/utils/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DatabaseService.init();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return MaterialApp(
      title: 'TaskFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: themeManager.currentTheme,
      home: const HomeScreen(),
    );
  }
}