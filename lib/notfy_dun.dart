import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_application/firebase_options.dart';
import 'package:women_safety_application/main.dart';

Future<void> sendNotificationToDevice(String title, String body) async {


  print('notification');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const String oneSignalRestApiKey =
      'os_v2_app_mfyhj42elbd5febwakisecemgp74msqtewwerdm4qsavnp7ulpn6giak7zt6s7hwkont5vm37odjworsa4xtrzps4g6v5s36lnu7n3q';
  const String oneSignalAppId = '617074f3-4458-47d2-9036-029122088c33';

  var playId = [];

  final addedData = await FirebaseFirestore.instance
      .collection('favorites')
      .where('userId', isEqualTo: (FirebaseAuth.instance.currentUser!.uid))
      .get();

      print('--------------------');

      print(addedData);


  
  final addedContacts = addedData.docs;
  if(addedContacts==null){
    return;
  }
  
  

  

  // Iterate over the contactList
  for (var contact in addedContacts) {

    print(contact.data()['phone']);


    final userQuery = await FirebaseFirestore.instance
      .collection('user')
      .where('phone', isEqualTo: contact.data()['phone'])
      .get();


    for (var playerId in userQuery.docs){
      playId.add(playerId.data()['playerId']);
      print(playerId.data());

    }


   
  }

  // Get the current position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

 

  



 

  // Use the position data in your notification
  var url = Uri.parse('https://api.onesignal.com/notifications?c=push');
  var notificationData = {
    "app_id": oneSignalAppId,
    "headings": {"en": title},
    "contents": {"en": body},
    "target_channel": "push",
    "include_player_ids": playId,
    "url": generateNearbyPoliceStationsUrl(startLat:position.latitude,startLng: position.longitude ), // Optionally, you can include a URL
    "data": {
      "latitude": position.latitude,
      "longitude": position.longitude,
    }
  };

  var headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "Basic $oneSignalRestApiKey",
  };

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notificationData),
    );
    if (response.statusCode == 200) {
      print("Notification Sent Successfully!");
      print(response.body);
    } else {
      print("Failed to send notification: ${response.body}");
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
}


String generateNearbyPoliceStationsUrl({
  required double startLat,
  required double startLng,
}) {
 final  link = 'https://www.google.com/maps/search/?api=1'
      '&query=Police+Station&location=$startLat,$startLng';


      return link;
}



Future<void> sendNotificationToSpecificUsers() async {
  final String oneSignalAppId = "617074f3-4458-47d2-9036-029122088c33";
  final String oneSignalRestApiKey = "os_v2_app_mfyhj42elbd5febwakisecemgp74msqtewwerdm4qsavnp7ulpn6giak7zt6s7hwkont5vm37odjworsa4xtrzps4g6v5s36lnu7n3q";


      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

     

  print(position);

  final  prefs =  await  SharedPreferences.getInstance();

    




      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

// Step 1: Fetch all users
final userQuery = await FirebaseFirestore.instance
      .collection('user')
      .get();

// Step 2: Filter users where isOnline is true and exclude the current user
final onlineUsers = userQuery.docs
    .where((doc) => doc['isOnline'] == true && doc.id != currentUserId)
    .toList();



       var playId = [];

      for (int i = 0; i < onlineUsers.length; i++){

         final playerId = onlineUsers[i]; // playerId

         


        await FirebaseFirestore.instance.collection('chats').add({
        'senderId': currentUserId,
        'receiverId': playerId.id,
        'message': generateNearbyPoliceStationsUrl(startLat:prefs.getDouble('lat')?? 0,startLng: prefs.getDouble('lng')?? 0 ),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print(playerId.data()['playerId']);




      playId.add(playerId.data()['playerId']);
     
    }


     print('pla===========yId');
        print(playId);

   





  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $oneSignalRestApiKey',
    },
    body: jsonEncode(<String, dynamic>{
      'app_id': oneSignalAppId,
      'include_player_ids': playId,
       "headings": {"en": 'Alert'},
      'contents': {'en': 'please help'},
      "android_channel_id":"dd516c67-fa36-4153-a4d9-1490e0224f75",
      "sound": "sos_sound", 
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
    print(response.body);
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

