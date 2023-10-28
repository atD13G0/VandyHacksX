import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:aeyes_3/Screens/TakePictureScreenAPI.dart';
import 'text_to_speech.dart'; // Make sure to import the TextToSpeech class
=======
import 'package:aeyes_3/Screens/TakePictureScreen.dart';
import 'package:aeyes_3/Screens/HomeScreen.dart';
>>>>>>> 2cbc89ca1befac10c344ee552ed5e8ad2d39b83e

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Setting the environment variable for Google Cloud Credentials
  Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] = 'rock-sorter-403218-c8e58de92b0d.json';

  Platform.environment['REPLICATE_API_TOKEN'] = 'your_replicate_api_token_here';

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
<<<<<<< HEAD
      home: TakePictureScreenAPI( // Set TakePictureScreenAPI as the home widget
=======
      home: CameraScreen(
>>>>>>> 2cbc89ca1befac10c344ee552ed5e8ad2d39b83e
        camera: firstCamera,
        speakFunction: speakText,
      ),
    ),
  );
}

Future<void> speakText(String text) async {
  TextToSpeech tts = TextToSpeech('rock-sorter-403218-c8e58de92b0d.json');
  await tts.speak(text);
}
