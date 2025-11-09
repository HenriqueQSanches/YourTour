import 'package:flutter/material.dart';
import 'screens/chat_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Chat',
      theme: ThemeData(
        primaryColor: const Color(0xFF6E44FF),
        scaffoldBackgroundColor: const Color(0xFF0F0B21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6E44FF),
          secondary: Color(0xFF8A2DE2),
          background: Color(0xFF0F0B21),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const ChatListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}