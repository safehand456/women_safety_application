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
  final Set<String> _addedContacts = {}; // Tracks added contact IDs

  @override
  void initState() {
    super.initState();
    _fetchContacts();
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

  void _onPlusIconPressed(DocumentSnapshot contact) {
    setState(() {
      _addedContacts.add(contact.id); // Mark the contact as added
    });

    final contactData = contact.data() as Map<String, dynamic>;
    final name = contactData['name'] ?? 'Unknown';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name added to your list!')),
    );

    // Add any additional functionality for the added contact here.
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
                    final isAdded = _addedContacts.contains(user.id); // Check if added

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
                        trailing: IconButton(
                          icon: Icon(
                            isAdded ? Icons.check : Icons.add,
                            color: isAdded
                                ? Colors.green
                                : Color.fromARGB(255, 235, 36, 179),
                          ),
                          onPressed: isAdded
                              ? null
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
