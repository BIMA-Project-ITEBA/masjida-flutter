import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjida/features/pagescreen/homescreen.dart';
// Import file SignInScreen yang baru kita buat
// import 'auth/screen/signupscreen.dart';
// import 'pagescreen/favoritescreen.dart';

void main() {
  // Memastikan Flutter binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  // Mengatur warna status bar agar sesuai dengan tema
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
        fontFamily: 'Inter', // Menggunakan font yang umum dan bersih
        scaffoldBackgroundColor: Colors.white,
      ),
      // MENGGANTI home MENJADI SignInScreen()
      home: const HomeScreen(),
    );
  }
}
