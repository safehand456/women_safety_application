import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_application/auth/loginscreen.dart';
import 'package:women_safety_application/auth/register.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/firebase_options.dart';
import 'package:women_safety_application/splashscreen.dart';
import 'package:women_safety_application/user/userinterface.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //Remove this method to stop OneSignal Debugging 
// OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

// OneSignal.initialize("a75f2425-3009-4129-8a6a-205277bdb5d2");

// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
// OneSignal.Notifications.requestPermission(true);
  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        fontFamily: 'robot'
      ),
    );
  }
}
