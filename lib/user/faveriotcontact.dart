import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteContactsScreen extends StatefulWidget {
  @override
  _FavoriteContactsScreenState createState() => _FavoriteContactsScreenState();
}

class _FavoriteContactsScreenState extends State<FavoriteContactsScreen> {
  List<Map<String, dynamic>> _appInstalledContacts = [];
  List<Map<String, dynamic>> _appNotInstalledContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Fetch favorites for the current user and categorize them
  Future<void> _fetchFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch favorite contacts from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();
        print(querySnapshot.docs.length);

      List<Map<String, dynamic>> favoritesData = querySnapshot.docs
          .map<Map<String, dynamic>>((doc) => {'data': doc.data(), 'docid': doc.id})
          .toList();

      List<Map<String, dynamic>> installedContacts = [];
      List<Map<String, dynamic>> notInstalledContacts = [];

      for (var contact in favoritesData) {
        String phone = contact['data']['phone'];
        print(phone);

        // Check if this phone number exists in the 'users' collection
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('user')
            .where('phone', isEqualTo: '7559838528')
            .get();

            print(userQuery.docs.length);

            

        if (userQuery.docs.isNotEmpty) {
          installedContacts.add(contact);
        } else {
          notInstalledContacts.add(contact);
        }
      }

      setState(() {
        _appInstalledContacts = installedContacts;
        _appNotInstalledContacts = notInstalledContacts;
      });

    } catch (e) {
      print('Error fetching contacts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Remove contact from favorites
  Future<void> _removeFromFavorites(String contactId, String docId) async {
    try {
      // Remove contact from Firestore
      await FirebaseFirestore.instance.collection('favorites').doc(docId).delete();

      setState(() {
        _appInstalledContacts.removeWhere((contact) => contact['data']['contactId'] == contactId);
        _appNotInstalledContacts.removeWhere((contact) => contact['data']['contactId'] == contactId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact removed from favorites')),
      );
    } catch (e) {
      print('Error removing contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Favorite Contacts')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _appInstalledContacts.isEmpty && _appNotInstalledContacts.isEmpty
              ? Center(child: Text('No favorite contacts found.'))
              : ListView(
                  children: [
                    if (_appInstalledContacts.isNotEmpty)
                      _buildContactSection('App Installed', _appInstalledContacts),
                    if (_appNotInstalledContacts.isNotEmpty)
                      _buildContactSection('App Not Installed', _appNotInstalledContacts),
                  ],
                ),
    );
  }

  // Widget to display a contact section
  Widget _buildContactSection(String title, List<Map<String, dynamic>> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...contacts.map((contact) {
          final contactData = contact['data'];
          final name = contactData['name'] ?? 'Unknown';
          final phone = contactData['phone'] ?? 'No phone';
          final contactId = contactData['contactId'];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: contactData['thumbnail'] != null
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(contactData['thumbnail']),
                    )
                  : Icon(Icons.person, color: Colors.purpleAccent),
              title: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'Phone: $phone',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () {
                  _removeFromFavorites(contactId, contact['docid']);
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
