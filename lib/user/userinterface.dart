import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_application/auth/contactlist.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/notfy_dun.dart';
import 'package:women_safety_application/user/camera.dart';
import 'package:women_safety_application/user/danger_location_screen.dart';
import 'package:women_safety_application/user/faveriotcontact.dart';
import 'package:women_safety_application/user/user_chat_list_screen.dart';
import 'package:women_safety_application/user/user_profile_screen.dart';
import 'package:women_safety_application/women_safty_community.dart';
import 'package:women_safety_application/women_safty_products_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAlertModeEnabled = false;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAlertModeState();
    _setUserOnlineStatus(true);
  }

  // Load Alert Mode from SharedPreferences
  Future<void> _loadAlertModeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAlertModeEnabled = prefs.getBool('alertMode') ?? false;
    });
  }

  // Update Firestore isOnline status
  Future<void> _setUserOnlineStatus(bool isOnline) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('user').doc(user.uid).update({
        'isOnline': isOnline,
      });
    }
  }

  // Show Exit Confirmation Dialog
  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App?'),
            content: Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  _setUserOnlineStatus(false); // Update Firestore
                  Navigator.of(context).pop(true); // Exit app
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Show Alert Mode Dialog
  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enable Alert Mode?'),
          content: Text(
              'This will activate the alert system to notify your contacts in case of emergency.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isAlertModeEnabled = false;
                });
                _saveAlertModeState(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alert Mode Disabled')),
                );
                Navigator.pop(context);
              },
              child: Text('Disable'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isAlertModeEnabled = true;
                });
                _saveAlertModeState(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alert Mode Enabled')),
                );
                Navigator.pop(context);
              },
              child: Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  // Save Alert Mode to SharedPreferences
  Future<void> _saveAlertModeState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alertMode', value);
  }

  // Logout user and update Firestore
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _setUserOnlineStatus(false); // Update Firestore

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed, // Handle back button
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });

            if (isAlertModeEnabled) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              final name = prefs.getString('auth_user');
              await sendNotificationToSpecificUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Alert sent successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Enable Alert Mode first')),
              );
            }

            setState(() {
              isLoading = false;
            });
          },
          label: isLoading ? Center(child: CircularProgressIndicator()) : Text('Send Alert'),
        ),
        appBar: AppBar(
          foregroundColor: const Color.fromARGB(255, 197, 9, 144),
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 226, 106, 206),
                  const Color.fromARGB(255, 232, 195, 221),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('Home Page'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                backgroundColor:
                    isAlertModeEnabled ? Colors.redAccent : Colors.grey.shade300,
                label: Text(
                  isAlertModeEnabled ? 'Alert Mode ON' : 'Alert Mode OFF',
                  style: TextStyle(
                    color: isAlertModeEnabled ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color.fromARGB(255, 243, 204, 236),
                  const Color.fromARGB(255, 232, 195, 221),
                ]),
              ),
            ),
            SingleChildScrollView( // Make the content scrollable
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //_buildButton(Icons.contact_page, 'Add Contact', ContactScreen()),
                      _buildButton(Icons.notification_important, 'Alert Mode', null, _showAlertDialog),
                      _buildButton(Icons.video_call, 'Camera', VideoRecordingScreen()),
                      _buildButton(Icons.chat, 'Chat', UserListScreen()),
                    
                      _buildButton(Icons.group, 'Community', WomenSafetyCommunityScreen()),
                      _buildButton(Icons.shopping_cart, 'Products', WomenSafetyProductsScreen()),
                      _buildButton(Icons.location_city, 'unsafe location', DangerousPlacesMapScreen()),

                      _buildButton(Icons.person, 'My Profile', ProfileScreen()),
                      
                      _buildButton(Icons.logout, 'Log out', null, _logout),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for creating buttons
  Widget _buildButton(IconData icon, String text, Widget? screen, [VoidCallback? onPressed]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(fixedSize: Size(300, 60)),
        onPressed: onPressed ?? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
        },
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}