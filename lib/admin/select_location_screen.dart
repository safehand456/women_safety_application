import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? selectedLocation;
  String? selectedAddress;
  GoogleMapController? mapController;

  void _onMapTap(LatLng latLng) async {
    setState(() {
      selectedLocation = latLng;
      selectedAddress = "Fetching address...";
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          selectedAddress =
              "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Unable to fetch address";
      });
    }
  }

  void _confirmSelection() {
    if (selectedLocation != null && selectedAddress != null) {
      Navigator.pop(context, {
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'address': selectedAddress,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a location first!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(20.5937, 78.9629), // Default (India)
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: _onMapTap,
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId("selected"),
                      position: selectedLocation!,
                      infoWindow: InfoWindow(title: "Selected Location"),
                    ),
                  }
                : {},
          ),
          if (selectedAddress != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(selectedAddress!, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmSelection,
        label: Text("Confirm Location"),
        icon: Icon(Icons.check),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
