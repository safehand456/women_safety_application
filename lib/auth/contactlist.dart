import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  List<String> addedId = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    bool permissionGranted = await FlutterContacts.requestPermission();

    if (permissionGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    } else {
      print("Permission denied");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) =>
                contact.displayName != null &&
                contact.displayName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addContactToFirebase(Contact contact) async {
    try {
      // Create a reference to the 'favorites' collection
      CollectionReference favorites = FirebaseFirestore.instance.collection('favorites');
      
      // Create a document for the contact
      await favorites.add({
        'userId' : FirebaseAuth.instance.currentUser?.uid,
        'name': contact.displayName,
        'phone': contact.phones.isNotEmpty ? contact.phones.first.number : 'No phone',
        'contactId': contact.id,  // Store the contact ID for identification
        'thumbnail': contact.thumbnail, // Store thumbnail if available
      });

      print('Contact added to Firebase');
    } catch (e) {
      print('Failed to add contact: $e');
    }
  }

  void _onPlusIconPressed(Contact contact) {
    setState(() {
      addedId.add(contact.id!);
    });
    // Add contact to Firebase when the plus icon is clicked
    _addContactToFirebase(contact);
  }

  void _onRemoveIconPressed(Contact contact) {
    setState(() {
      addedId.remove(contact.id!);
    });
    // Additional logic can be added here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: Column(
        children: [
          // Search TextField with black border and hint text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Contacts',
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: _onSearchChanged,
            ),
          ),
          // Loading Indicator or List
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      final name = contact.displayName ?? 'Unknown';
                      final phone = contact.phones.isNotEmpty
                          ? contact.phones.first.number ?? 'No phone'
                          : 'No phone';
                      final isAdded = addedId.contains(contact.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: contact.thumbnail != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      MemoryImage(contact.thumbnail!),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.purpleAccent,
                                ),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: $phone'),
                            ],
                          ),
                          trailing: _isLoading
                              ? CircularProgressIndicator()
                              : IconButton(
                                  icon: Icon(
                                    isAdded ? Icons.remove : Icons.add,
                                    color: isAdded
                                        ? Colors.green
                                        : Color.fromARGB(255, 235, 36, 179),
                                  ),
                                  onPressed: isAdded
                                      ? () => _onRemoveIconPressed(contact)
                                      : () => _onPlusIconPressed(contact),
                                ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
