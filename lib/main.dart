import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/seed_user_page.dart';

void main() {
  runApp(const TeamBuilderApp());
}

class TeamBuilderApp extends StatelessWidget {
  const TeamBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Team Builder',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // 🌙 โหมดมืด
        scaffoldBackgroundColor: Colors.black, // พื้นหลังดำ
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[800]!,
          secondary: Colors.grey[600]!,
          surface: Colors.grey[900]!,
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.white70,
          onSurface: Colors.white70,
          onBackground: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: const SeedMemberPage(), // ✅ หน้าหลักเดิม
    );
  }
}
