import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DangerousPlacesMapScreen extends StatefulWidget {
  @override
  _DangerousPlacesMapScreenState createState() => _DangerousPlacesMapScreenState();
}

class _DangerousPlacesMapScreenState extends State<DangerousPlacesMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Initial map position (you can set this to a default location)
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.24835535991846, 75.78391537070274), // Example: Kozhikode, India
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadDangerousPlaces();
  }

  // Fetch dangerous places from Firestore
  Future<void> _loadDangerousPlaces() async {
    final querySnapshot = await _firestore.collection('dangerous_places').get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final latitude = data['latitude'] as double;
      final longitude = data['longitude'] as double;
      final address = data['address'] as String;
      final description = data['description'] as String;

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: address,
              snippet: description,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dangerous Places'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
      ),
    );
  }
}