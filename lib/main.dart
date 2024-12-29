import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
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


OneSignal.initialize("617074f3-4458-47d2-9036-029122088c33");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
OneSignal.Notifications.requestPermission(true);
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
