import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjida/features/auth/screen/signinscreen.dart';
import 'package:masjida/features/auth/screen/signupscreen.dart';
// IMPORT BARU DENGAN PATH YANG BENAR
import 'package:masjida/features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      // Memanggil HomeScreen dari import yang benar
      home: const SignUpScreen(),
    );
  }
}

