import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return _buildUserCard(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              user['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              'Email: ${user['email'] ?? 'No Email'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Phone
            Text(
              'Phone: ${user['phone'] ?? 'No Phone'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Online Status
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontSize: 14),
                ),
                Icon(
                  Icons.circle,
                  size: 12,
                  color: user['isOnline'] == true ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  user['isOnline'] == true ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    color: user['isOnline'] == true ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Player ID
            
          ],
        ),
      ),
    );
  }
}