import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:women_safety_application/firebase_options.dart';
import 'package:women_safety_application/notfy_dun.dart';
import 'package:women_safety_application/splashscreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_application/user/user_chat_list_screen.dart';
import 'package:women_safety_application/user/user_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userId =  FirebaseAuth.instance.currentUser?.uid;

  if(userId != null){
       FirebaseFirestore.instance.collection('user').doc(userId).update({
        'isOnline' :true,

       });

  }

  

  // Initialize OneSignal
  OneSignal.shared.setAppId("617074f3-4458-47d2-9036-029122088c33");
  //OneSignal.Notifications.requestPermission(true);


  OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  print('llllll');
  // Handle subscription changes
  String? userId = changes.to.userId;
  if (userId != null) {
    // Save this userId to your server or database
    print("OneSignal User ID: $userId");
  }
});
    final  ds = await OneSignal.shared.getDeviceState();
    print(ds?.userId);




  // Request permissions
  await _requestPermissions();

  // Initialize and start background service
  await initializeBackgroundService();


  OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    print('ooooooooooooooooooooooooooosiwjsiwjiswjsiwjisjw');
    // Navigate to a specific page based on the notification data
    Navigator.push(
      navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => UserListScreen()),
    );
  });

  runApp( MainApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
   MainApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: SplashScreen(),
      theme: ThemeData(
        fontFamily: 'robot',
      ),
    );
  }
}

// Function to request permissions
Future<void> _requestPermissions() async {
  await [
    Permission.location,
    Permission.contacts,
    Permission.microphone
  ].request();
}

// Initialize background service
Future<void> initializeBackgroundService() async {

  final service = FlutterBackgroundService();

  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (service) => true,
    ),
  );

  await service.startService();
}

// Background service logic
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final stt.SpeechToText speech = stt.SpeechToText();

  Future<void> startListening() async {
    bool initialized = await speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == 'notListening' || status == 'done') {
          print('Restarting speech listener...');
        Future.delayed(const Duration(seconds: 2), startListening); // Restart after delay
// Restart listening
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        Future.delayed(const Duration(seconds: 2), startListening); // Restart after delay
      },
    );

    if (initialized) {
      print("Speech recognition started");
      speech.listen(
        onResult: (result) async {

          print(result.recognizedWords.toLowerCase());
          if (result.recognizedWords.toLowerCase().contains("hello")) {
            print('help');
            await sendNotificationToSpecificUsers();
          }
        },
        listenFor: const Duration(days: 365), // Extended listening
        pauseFor: const Duration(minutes: 5),
        cancelOnError: false,
      );
    } else {
      print("Failed to initialize speech recognition");
    }
  }

  startListening(); // Start listening
}

// Trigger the SOS alert
void _triggerBackgroundSOS() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  String location = "Lat: ${position.latitude}, Lng: ${position.longitude}";

  print('SOS triggered with location: $location');
  // TODO: Send location data to emergency contacts or API
}
