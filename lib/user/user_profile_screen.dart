import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _uid;
  late String _name;
  late String _email;
  late String _phone;
  late String _playerId;
  bool _isOnline = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user data from Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('user').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _uid = user.uid;
          _name = doc['name'];
          _email = doc['email'];
          _phone = doc['phone'];
          _playerId = doc['playerId'];
          _isOnline = doc['isOnline'];

          // Set text field values
          _nameController.text = _name;
          _emailController.text = _email;
          _phoneController.text = _phone;
        });
      }
    }
  }

  // Update user data in Firestore
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('user').doc(_uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'isOnline': _isOnline,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Online Status'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Player ID: $_playerId', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text('UID: $_uid', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}