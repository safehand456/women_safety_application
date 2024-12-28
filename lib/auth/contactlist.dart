import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<Map<String,dynamic>> _addedContacts = []; // Tracks added contact IDs
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  late final addedContacts;
  List addedId = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _fetchAddedContacts();
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
          addedId.add(contact['uid']); // Extract and add the uid to addedId
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
      floatingActionButton: FloatingActionButton(onPressed: () {
        
      },),
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
                if (!snapshot.hasData || _filteredContacts.isEmpty) {
                  return Center(child: Text('No contacts found'));
                }

                return ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final user = _filteredContacts[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final name = userData['name'] ?? 'Unknown';
                    final email = userData['email'] ?? 'No email';
                    final phone = userData['phone'] ?? 'No phone';
                    final isAdded = addedId.contains(user.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(
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
                            Text('Email: $email'),
                            Text('Phone: $phone'),
                          ],
                        ),
                        trailing:isLoading?CircularProgressIndicator(): IconButton(
                          icon: Icon(
                            isAdded ? Icons.remove : Icons.add,
                            color: isAdded
                                ? Colors.green
                                : Color.fromARGB(255, 235, 36, 179),
                          ),
                          onPressed: isAdded
                              ? ()=> _onRemoveIconPressed(user)
                              : () => _onPlusIconPressed(user), // Disable if added
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
