import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _image;
  List<Face> faces = [];
  bool _isLoading = false;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
        _isLoading = true;
      });
      await _detectFaces(_image!);
    } catch (e) {
      _showError("Failed to pick image.");
    }
  }

  Future _detectFaces(File img) async {
    try {
      final options = FaceDetectorOptions(enableClassification: true, enableLandmarks: true);
      final faceDetector = FaceDetector(options: options);
      final inputImage = InputImage.fromFilePath(img.path);
      faces = await faceDetector.processImage(inputImage);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showError("Failed to detect faces.");
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Recognition"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _image == null
                    ? Text("Upload photo to detect faces")
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.blueAccent)
                    : Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Take a Photo"),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Upload a Photo"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (faces.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      "Faces detected: ${faces.length}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}