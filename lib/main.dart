import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:aeyes_3/Screens/QuickScanScreen.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
<<<<<<< HEAD
      home: homeScreen(
=======
      home:QuickScanScreen(
>>>>>>> e12f8c9fb7a5ccfd7328ec64cedbf616f0589b49
        camera: firstCamera,
        onResultReceived: (output) async {
          FlutterTts flutterTts = FlutterTts();
          await flutterTts.speak(output);
        },
      ),
    ),
  );
}
