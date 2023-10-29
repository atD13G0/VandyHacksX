import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:aeyes_3/Screens/DisplayPictureScreen.dart';

import 'dart:typed_data';

import 'package:image/image.dart' as img; // Import the image package.
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// A screen that allows users to take a picture using a given camera.
class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({
    Key? key,
    required this.camera,
    required this.onResultReceived,
  }) : super(key: key);

  final CameraDescription camera;
  final Function(String) onResultReceived;

  @override
  QuickScanScreenState createState() => QuickScanScreenState();
}

class QuickScanScreenState extends State<QuickScanScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Scan')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
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
            await sendImageToApi(image, widget.onResultReceived); // Passing the callback here
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

Future<void> sendImageToApi(XFile imagePath, Function(String) onResultReceived) async {
  Uint8List pngBytes = await convertXFileToPng(imagePath); // Assuming you have this function implemented
  String base64Img = base64Encode(pngBytes);

  final response = await http.post(
    Uri.parse('https://api.replicate.com/v1/predictions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token your_token_here',
    },
    body: jsonEncode({
      'version': 'your_version_here',
      'input': {'image': 'your_image_url_here'},
    }),
  );

  print(response.statusCode);

  if (response.statusCode == 201) {
    Map<String, dynamic> responseData = jsonDecode(response.body);
    String outputText = responseData['id']; 

    String? apiOutput = await fetchReplicateData(outputText); // Assuming you have this function implemented
    if (apiOutput != null) {
      onResultReceived(apiOutput); // Send the output to the callback function
    }
  } else {
    print('Failed to send image to API: ${response.statusCode}');
  }
}


  Future<String?> fetchReplicateData(String id) async {
    final String apiUrl = "https://api.replicate.com/v1/predictions/$id";
    final String token = "r8_BbVMkGSRAZWPnMwNA5vQaNuEmh5ZxTd0838JH";
    print(apiUrl);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String status = responseData['status']; // Adjust based on actual API response structure
      print(status);
      if(status == "succeeded"){
        print(responseData['output']);
      } else if(status == "failed"){
        print(responseData['logs']);
      } else {
        await Future.delayed(const Duration(seconds: 1), (){});
        fetchReplicateData(id);
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  Future<Uint8List> convertXFileToPng(XFile xfile) async {
    // Read the image file.
    final File imageFile = File(xfile.path);

    // Decode the image using the image package.
    final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

    // Encode the image as a PNG (returns a List<int>).
    final List<int> pngBytesList = img.encodePng(image);

    // Convert the List<int> to a Uint8List.
    final Uint8List pngBytes = Uint8List.fromList(pngBytesList);

    return pngBytes;
  }

  Future<File> savePngImageAsTemporaryFile(XFile xfile) async {
    Uint8List pngBytes = await convertXFileToPng(xfile);

    // Get the temporary directory.
    final tempDir = await getTemporaryDirectory();

    // Create a temporary file in the temporary directory with a unique name.
    final tempFile = File(join(tempDir.path, 'temp_image.png'));

    // Write the PNG bytes to the temporary file.
    await tempFile.writeAsBytes(pngBytes);

    return tempFile;
  }

