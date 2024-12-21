import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_application/auth/loginscreen.dart';
import 'package:women_safety_application/auth/register.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/firebase_options.dart';
import 'package:women_safety_application/user/userinterface.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChooseScreen(
      ),
      theme: ThemeData(
        fontFamily: 'robot'
      ),
    );
  }
}
