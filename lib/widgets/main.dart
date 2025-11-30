// main.dart
import 'package:concessoapp/services/shared_pref_service.dart';
import 'package:concessoapp/views/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../services/shared_pref_service.dart';
import 'firebase_options.dart'; // <-- this is important!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase properly for web and other platforms
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  await SharedPrefService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTO Student Services',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
