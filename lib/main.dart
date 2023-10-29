import 'dart:async';
import 'dart:io';

import 'package:aeyes_3/Screens/QuickScanScreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:aeyes_3/Screens/TakePictureScreenAPI.dart';
// import 'text_to_speech.dart'; // Make sure to import the TextToSpeech class

import 'package:aeyes_3/Screens/TakePictureScreen.dart';
import 'package:aeyes_3/Screens/HomeScreen.dart';


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
      home: homeScreen(
        camera: firstCamera,
        // speakFunction: speakText,
      ),
    ),
  );
}
