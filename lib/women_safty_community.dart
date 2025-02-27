import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_application/Location_picker_screen.dart';

class WomenSafetyCommunityScreen extends StatefulWidget {
  @override
  _WomenSafetyCommunityScreenState createState() =>
      _WomenSafetyCommunityScreenState();
}

class _WomenSafetyCommunityScreenState
    extends State<WomenSafetyCommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isLoading = false;

  // Function to upload post to Firestore
  Future<void> _uploadPost() async {
    if (_postController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please add a description and location!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance.collection('Posts').add({
      'description': _postController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'location': _locationController.text,
      'latitude': _selectedLocation?.latitude,
      'longitude': _selectedLocation?.longitude,
    });

    _postController.clear();
    _locationController.clear();
    setState(() {
      _selectedLocation = null;
      _isLoading = false;
    });

    Navigator.pop(context); // Close the popup after posting
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Post uploaded successfully!")));
  }

  // Callback when location is selected
  void onLocationSelected(double latitude, double longitude) async {
    try {
      // Convert latitude and longitude to a human-readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";

        setState(() {
          _selectedLocation = LatLng(latitude, longitude);
          _locationController.text = address; // Update location text field
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch address. Please try again.")),
      );
    }
  }

  // Function to get current location
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied.")),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  // Function to show the add post popup
  void _showAddPostPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("Add a Post", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write a short description...",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: "Enter location (e.g., New York, USA)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    Position? position = await _getCurrentLocation();
                    if (position != null) {
                      final location = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerScreen(
                            latitude: position.latitude,
                            longitude: position.longitude,
                            onLocationSelected: onLocationSelected,
                          ),
                        ),
                      );
                      if (location != null) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      }
                    }
                  },
                  child: Text("Select Location from Map"),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: _isLoading ? null : _uploadPost,
              child: _isLoading ? CircularProgressIndicator() : Text("Post"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Women Safety Community"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildPostList()), // Display posts
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostPopup(context),
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.pink,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  // Function to fetch and display posts
  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: Colors.pinkAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[700]),
                      ),
                      title: Text(
                        "Anonymous User", // Generic placeholder
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        post['timestamp']?.toDate().toString() ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        post['description'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    if (post['location'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 16),
                            SizedBox(width: 5),
                            Text(
                              post['location'],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueGrey),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.map, color: Colors.blue),
                              onPressed: () {
                                if (post['latitude'] != null &&
                                    post['longitude'] != null) {
                                  final url =
                                      "https://www.google.com/maps/search/?api=1&query=${post['latitude']},${post['longitude']}";
                                  launchUrl(Uri.parse(url));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text("Comments", style: TextStyle(fontSize: 14))),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Posts')
                          .doc(post.id)
                          .collection('Comments')
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator());

                        var comments = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            var comment = comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.grey[700]),
                              ),
                              title: Text(comment['text']),
                              subtitle: Text(
                                comment['timestamp']?.toDate().toString() ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (text) {
                          FirebaseFirestore.instance
                              .collection('Posts')
                              .doc(post.id)
                              .collection('Comments')
                              .add({
                            'text': text,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}