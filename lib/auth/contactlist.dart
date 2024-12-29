import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for permission handling
import 'package:women_safety_application/notfy_dun.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('user');
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allContacts = [];
  List<DocumentSnapshot> _filteredContacts = [];
  final List<Map<String, dynamic>> _addedContacts = []; // Tracks added contact IDs
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  late final addedContacts;
  List addedId = [];

  List<String> playerIds = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check permission on init
    _fetchContacts();
    _fetchAddedContacts();
  }

  // Check for location permission and request if necessary
  void _checkLocationPermission() async {
    // Check the current location permission status
    PermissionStatus status = await Permission.location.status;

    // If permission is granted, proceed with the functionality
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      // If not granted, request the permission
      PermissionStatus newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        print('Location permission granted after request');
      } else {
        // Handle the case where permission is denied
        print('Location permission denied');
        _handlePermissionDenied(); // Handle denial
      }
    }
  }

  // Handle permission denied case by showing a dialog
  void _handlePermissionDenied() async {
    bool isOpenSettings = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission'),
        content: Text('We need location access to show nearby police stations. Would you like to enable it in settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;

    if (isOpenSettings) {
      openAppSettings(); // Open the app settings for the user to enable location
    }
  }

  void _fetchAddedContacts() async {
    try {
      final addedData = await FirebaseFirestore.instance
          .collection('contact')
          .doc(userId)
          .get();

      if (addedData.exists) {
        addedContacts = addedData.data();
        final contactList = addedContacts['contactList'] as List<dynamic>;

        // Iterate over the contactList
        for (var contact in contactList) {
          if (contact is Map<String, dynamic>) {
            print('--------------------');
            addedId.add(contact['uid']);
          }
        }

        setState(() {
          // Trigger rebuild to reflect the updated state
        });
      }
    } catch (e) {
      print('Error fetching added contacts: $e');
    }
  }

  void _fetchContacts() {
    _userCollection.snapshots().listen((snapshot) {
      setState(() {
        _allContacts = snapshot.docs;
        _filteredContacts = _allContacts;
      });
    });
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _allContacts;
      });
    } else {
      setState(() {
        _filteredContacts = _allContacts
            .where((doc) {
              final name = (doc.data() as Map<String, dynamic>)['name'] ?? '';
              return name.toLowerCase().contains(query.toLowerCase());
            })
            .toList();
      });
    }
  }

  void _onPlusIconPressed(DocumentSnapshot contact) async {
    final contactId = contact.id; // Get the unique ID of the contact
    final contactData = contact.data() as Map<String, dynamic>;
    final name = contactData['name'] ?? 'Unknown';

    setState(() {
      isLoading = true;
    });

    try {
      // Check if the document already exists; if not, create it
      final userDocRef = FirebaseFirestore.instance.collection('contact').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Update the existing document by adding to the contactList
        await userDocRef.update({
          'contactList': FieldValue.arrayUnion([{
            'uid': contactId,
            ...contactData, // Include additional contact data if needed
          }]),
        });
      } else {
        // Create a new document with the userId and contactList
        await userDocRef.set({
          'uid': userId,
          'contactList': [{
            'uid': contactId,
            ...contactData, // Include additional contact data if needed
          }],
        });
      }

      // Update local state
      setState(() {
        addedId.add(contactId); // Add to the local list of added IDs
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to your list!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add $name')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onRemoveIconPressed(DocumentSnapshot contact) async {
    final contactId = contact.id; // Get the unique ID of the contact
    final contactData = contact.data() as Map<String, dynamic>;
    final name = contactData['name'] ?? 'Unknown';

    setState(() {
      isLoading = true;
    });

    try {
      // Reference the user's document in Firestore
      final userDocRef = FirebaseFirestore.instance.collection('contact').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Remove the specific contact from the contactList
        await userDocRef.update({
          'contactList': FieldValue.arrayRemove([{
            'uid': contactId,
            ...contactData, // Match the structure of the contact data stored in Firestore
          }]),
        });

        // Update local state
        setState(() {
          addedId.remove(contactId); // Remove from the local list of added IDs
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name removed from your list!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name is not in your list!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove $name')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        foregroundColor: const Color.fromARGB(255, 235, 36, 179),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 244, 148, 218),
                const Color.fromARGB(255, 232, 195, 221),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Contact List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: _userCollection.snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error loading contacts'));
      }
      if (!snapshot.hasData) {
        return Center(child: Text('No contacts found'));
      }

      // Filter the contacts to exclude specific UID
      final excludedUid = FirebaseAuth.instance.currentUser!.uid;
      final filteredContacts = snapshot.data!.docs.where((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        return userData['uid'] != excludedUid;
      }).toList();

      if (filteredContacts.isEmpty) {
        return Center(child: Text('No contacts found'));
      }

      return ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final user = filteredContacts[index];
          final userData = user.data() as Map<String, dynamic>;
          final name = userData['name'] ?? 'Unknown';
          final email = userData['email'] ?? 'No email';
          final phone = userData['phone'] ?? 'No phone';
          final isAdded = addedId.contains(user.id);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.purpleAccent,
              ),
              title: Text(
                name,
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text('Phone: $phone\nEmail: $email'),
              trailing: isAdded
                  ? IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => _onRemoveIconPressed(user),
                    )
                  : IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () => _onPlusIconPressed(user),
                    ),
            ),
          );
        },
      );
    },
  ),
),

         
        
        
        
        ],
      ),
    );
  }
}
