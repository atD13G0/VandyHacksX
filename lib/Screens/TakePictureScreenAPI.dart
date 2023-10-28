import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// A screen that allows users to take a picture using a given camera.
class TakePictureScreenAPI extends StatefulWidget {
  const TakePictureScreenAPI({
    super.key,
    required this.camera,
    required this.speakFunction,
  });

  final CameraDescription camera;
  final Function(String) speakFunction;  // <-- Add this

  @override
  TakePictureScreenAPIState createState() => TakePictureScreenAPIState();
}

class TakePictureScreenAPIState extends State<TakePictureScreenAPI> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> sendImageToApi(String imagePath, Function(String) speakText) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token r8_2r3g1FhrBZgEIagYwq5UFUJdcKHGanG2MUSG2',
        },
        body: jsonEncode({
        'version': '9109553e37d266369f2750e407ab95649c63eb8e13f13b1f3983ff0feb2f9ef7',
        'input': {'image': base64Image},
        }),
    );

    if (response.statusCode == 200) {
        // Parse the response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String outputText = responseData['output']; // Adjust based on actual API response structure

        // Call the speakText function to read the output aloud
        speakText(outputText);
    } else {
        print('Failed to send image to API: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            await sendImageToApi(image.path, widget.speakFunction);  // Pass the function here
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
