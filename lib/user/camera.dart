import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore

class VideoRecordingScreen extends StatefulWidget {
  @override
  _VideoRecordingScreenState createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  late String _videoPath;

  // Cloudinary Configuration
  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dgj5jg32k', 
    apiKey: '459751488787844', 
    apiSecret: 'vGcQWzNzvDHnsgqFGgawfp7LRsg',
  );

  // Firebase Auth instance to get current user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Firestore instance to save video URL
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get available cameras
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
    await _cameraController.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });

    // Check if the file exists before uploading it
    if (await File(_videoPath).exists()) {
      print('Video file exists at path: $_videoPath');
      _uploadVideoToCloudinary(_videoPath);
    } else {
      print('Error: Video file not found at path $_videoPath');
    }
  }
}


  Future<void> _uploadVideoToCloudinary(String videoPath) async {
    File videoFile = File(videoPath);
    print(videoFile.path);

    try {

      print('ccccccccc');
      // Upload video to Cloudinary
      final result = await cloudinary.upload(
        file: videoPath,
        resourceType: CloudinaryResourceType.video,
        folder: 'flutter_videos', // optional: specify folder in Cloudinary
      );

      // If the upload is successful, print the URL of the video
      if (result.isSuccessful) {
        final videoUrl = result.secureUrl;
        print('Video uploaded successfully! Video URL: $videoUrl');

        // Save the video URL to Firestore
        await _saveVideoUrlToFirestore(videoUrl!);
      } else {
        print('Video upload failed: ${result.error}');
      }
    } catch (e) {
      print('Error uploading video: $e');
    }
  }

  // Save video URL to Firestore with user ID
  Future<void> _saveVideoUrlToFirestore(String videoUrl) async {
    try {
      // Get the current user's ID
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user is logged in');
        return;
      }

      // Save video URL to Firestore
      await _firestore.collection('videos').add({
        'userId': user.uid,  // User's ID
        'videoUrl': videoUrl,  // Video URL from Cloudinary
        'timestamp': FieldValue.serverTimestamp(),  // Optional: add a timestamp
      });

      print('Video URL saved to Firestore');
    } catch (e) {
      print('Error saving video URL to Firestore: $e');
    }
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
        children: <Widget>[
          Expanded(
            child: CameraPreview(_cameraController),
          ),
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
        ],
      ),
    );
  }
}
