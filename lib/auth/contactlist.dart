import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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

  void _onPlusIconPressed(Contact contact) {
    setState(() {
      addedId.add(contact.id!);
    });
    // Additional logic can be added here
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
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search Contacts',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                            backgroundImage: MemoryImage(contact.thumbnail!),
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
    );
  }
}
