import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_application/auth/contactlist.dart';
import 'package:women_safety_application/choosig.dart';
import 'package:women_safety_application/notfy_dun.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAlertModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAlertModeState();
  }

  Future<void> _loadAlertModeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAlertModeEnabled = prefs.getBool('alertMode') ?? false;
    });
  }

  Future<void> _saveAlertModeState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alertMode', value);
  }

  void _showAlertDialog(BuildContext context) {
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored values
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ChooseScreen(),), (route) => false,);
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });

          if (isAlertModeEnabled) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final name = prefs.getString('auth_user');
            await sendNotificationToDevice(
                'Alert', '$name is in danger! Please help!');
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
        label: isLoading
            ? Center(child: CircularProgressIndicator())
            : Text('Send Alert'),
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
              backgroundColor: isAlertModeEnabled
                  ? Colors.redAccent
                  : Colors.grey.shade300,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(fixedSize: Size(300, 60)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactListScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.contact_page),
                    label: Text(
                      'Add Contact',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 204, 50, 158),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(fixedSize: Size(300, 60)),
                    onPressed: () {
                      _showAlertDialog(context);
                    },
                    icon: Icon(Icons.notification_important),
                    label: Text(
                      'Alert Mode',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 204, 50, 158),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(fixedSize: Size(300, 60)),
                    onPressed: _logout,
                    icon: Icon(Icons.logout),
                    label: Text(
                      'Log out',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 204, 50, 158),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
