import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_application/user/user_chat_screen.dart';

class UserListScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Colors.pink.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('user').snapshots(), // Fetch users collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          var users = snapshot.data!.docs;
          var currentUserId = _auth.currentUser?.uid;

          // Sort users: Online users first
          users.sort((a, b) {
  bool aIsOnline = a['isOnline'] ?? false;
  bool bIsOnline = b['isOnline'] ?? false;

  // Online users come first
  if (aIsOnline && !bIsOnline) {
    return -1; // a comes before b
  } else if (!aIsOnline && bIsOnline) {
    return 1; // b comes before a
  } else {
    return 0; // no change in order
  }
});



          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userId = user.id;
              var userName = user['name'];
              bool isOnline = user['isOnline'] ?? false;

              // Don't show the current user in the list
              if (userId == currentUserId) {
                return SizedBox.shrink();
              }

              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('chats')
                    .where('senderId', isEqualTo: currentUserId)
                    .where('receiverId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .get(), // Fetch last message
                builder: (context, messageSnapshot) {
                  String lastMessage = '';
                  if (messageSnapshot.connectionState == ConnectionState.done &&
                      messageSnapshot.hasData &&
                      messageSnapshot.data!.docs.isNotEmpty) {
                    var lastMessageData = messageSnapshot.data!.docs.first;
                    lastMessage = lastMessageData['message'];
                  }

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        if (isOnline) // Show green dot if user is online
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(userName),
                    subtitle: Text(
                      lastMessage.isNotEmpty ? lastMessage : (isOnline ? 'Online' : 'Offline'),
                      style: TextStyle(
                        color: isOnline ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: userId,
                            receiverName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}