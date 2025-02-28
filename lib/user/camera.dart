import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator

class VideoRecordingScreen extends StatefulWidget {
  @override
  _VideoRecordingScreenState createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  bool _isLoading = false;
  late String _videoPath;

  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dgj5jg32k', 
    apiKey: '459751488787844', 
    apiSecret: 'vGcQWzNzvDHnsgqFGgawfp7LRsg',
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _initializeCamera();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.location.request();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _cameraController.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoPath = filePath;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      if (await File(file.path).exists()) {
        print('Video file exists at path: ${file.path}');
        _uploadVideoToCloudinary(file.path);
        Navigator.pop(context);
      } else {
        print('Error: Video file not found at path ${file.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Video file not found')),
        );
      }
    }
  }

  Future<void> _uploadVideoToCloudinary(String videoPath) async {
    setState(() {
      _isLoading = true;
    });

    File videoFile = File(videoPath);
    print('Video file path: ${videoFile.path}');

    try {
      print('Starting Cloudinary upload...');
      final result = await cloudinary.upload(
        file: videoPath,
        resourceType: CloudinaryResourceType.video,
        folder: 'flutter_videos',
      );

      if (result.isSuccessful) {
        final videoUrl = result.secureUrl;
        print('Video uploaded successfully! Video URL: $videoUrl');

        // Get current location
        Position position = await _getCurrentLocation();

        // Save video URL and location to Firestore
        await _saveVideoUrlToFirestore(videoUrl!, position.latitude, position.longitude);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded successfully!')),
        );
      } else {
        print('Video upload failed: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video upload failed: ${result.error}')),
        );
      }
    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveVideoUrlToFirestore(String videoUrl, double latitude, double longitude) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user is logged in');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in')),
        );
        return;
      }

      await _firestore.collection('videos').add({
        'userId': user.uid,
        'videoUrl': videoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Video URL and location saved to Firestore');
    } catch (e) {
      print('Error saving video URL to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving video URL to Firestore: $e')),
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
      throw Exception("Location permission denied");
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recording'),
      ),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_cameraController)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    size: 50,
                    color: Colors.red,
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
