import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // For address lookup

class AdminDangerPlacesScreen extends StatefulWidget {
  const AdminDangerPlacesScreen({super.key});

  @override
  _AdminDangerPlacesScreenState createState() => _AdminDangerPlacesScreenState();
}

class _AdminDangerPlacesScreenState extends State<AdminDangerPlacesScreen> {
  LatLng? selectedLocation;
  String? selectedAddress; // To store the selected address
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Get the current location
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // Convert latitude and longitude to an address
  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.locality}, ${place.country}";
        setState(() {
          selectedAddress = address;
          _addressController.text = address; // Update the address text field
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch address. Please try again.")),
      );
    }
  }

  // Save the dangerous place to Firestore
  void _saveDangerousPlace() async {
    if (selectedLocation != null &&
        _descriptionController.text.isNotEmpty &&
        selectedAddress != null) {
      await FirebaseFirestore.instance.collection('dangerous_places').add({
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'description': _descriptionController.text,
        'address': selectedAddress, // Save the address
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dangerous place added successfully!")),
      );

      _descriptionController.clear();
      _addressController.clear();
      Navigator.pop(context); // Close the popup
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a location and enter a description!")),
      );
    }
  }

  // Open the dialog to add a dangerous place
  void _openAddDangerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Dangerous Place"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Enter Description"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address"),
                readOnly: true, // Prevent manual editing
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Open the map to select a location
                  final location = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        initialLocation: selectedLocation,
                      ),
                    ),
                  );
                  if (location != null) {
                    setState(() {
                      selectedLocation = location;
                    });
                    // Fetch the address for the selected location
                    await _getAddressFromLatLng(location);
                  }
                },
                child: Text("Select Location on Map"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveDangerousPlace,
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dangerous Places"),
        backgroundColor: Colors.pink.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dangerous_places')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No dangerous places added yet."));
          }

          var places = snapshot.data!.docs;

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              var place = places[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text(place['description']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${place['latitude']}, ${place['longitude']}"),
                      Text("Address: ${place['address']}"), // Display the address
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('dangerous_places')
                          .doc(place.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Dangerous place removed")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: _openAddDangerDialog,
        child: Icon(Icons.add_location_alt),
      ),
    );
  }
}

// Map Screen to select a location
class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapScreen({this.initialLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                Navigator.pop(context, _selectedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a location!")),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation ?? LatLng(0, 0), // Default location
          zoom: 15,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId("selectedLocation"),
                  position: _selectedLocation!,
                ),
              }
            : {},
      ),
    );
  }
}