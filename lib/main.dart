// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart';
import 'profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_code_screen.dart';
import 'screens/reset_password_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar SQLite por plataforma
  if (kIsWeb) {
    // Web: usa IndexedDB via sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop nativo
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } // Android/iOS utilizam a factory padrão do sqflite
  
  // Inicializar o banco de dados (todas as plataformas com sua factory correspondente)
  try {
    await DatabaseHelper().database;
    print('Banco de dados inicializado com sucesso');
  } catch (e) {
    print('Erro ao inicializar banco de dados: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtour',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white70),
          floatingLabelStyle: const TextStyle(color: Colors.purpleAccent),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-code': (context) => const VerifyCodeScreen(email: ''),
        '/reset-password': (context) => const ResetPasswordScreen(email: ''),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
