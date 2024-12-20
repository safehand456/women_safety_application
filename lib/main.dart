import 'package:flutter/material.dart';
import 'package:women_safety_application/auth/loginscreen.dart';
import 'package:women_safety_application/auth/register.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/user/userinterface.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChooseScreen(
      ),
      theme: ThemeData(
        fontFamily: 'robot'
      ),
    );
  }
}
