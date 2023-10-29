import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;


class entire_run extends StatefulWidget {
  const entire_run({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  _entire_runState createState() => _entire_runState();
}

enum TtsState { playing, stopped }

class _entire_runState extends State<entire_run> {
  //camera controllers
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  //take to speech
  late FlutterTts _flutterTts;
  String? _tts;
  TtsState _ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();

    //initialize text to speech
    initTts();

    // initialize a CameraController.
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _flutterTts.stop();
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        print("Error: $message");
        _ttsState = TtsState.stopped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Scan')),
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
          print("hello world1");
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;
            _tts = "hello world";
            print(_tts);
            if (_ttsState == TtsState.stopped) {
              print("speaking now!");
              //call api for text
              await sendImageToApi(image);
            } else {
              print("not yet!");
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  // Widget input() => Container(
  //       alignment: Alignment.topCenter,
  //       padding: const EdgeInsets.all(25.0),
  //       child: TextField(
  //         onChanged: (String value) {
  //           setState(() {
  //             _tts = value;
  //           });
  //         },
  //       ),
  //     );

  // Widget button() {
  //   if (_ttsState == TtsState.stopped) {
  //     return TextButton(onPressed: speak, child: const Text('Play'));
  //   } else {
  //     return TextButton(onPressed: stop, child: const Text('Stop'));
  //   }
  // }

  Future speak() async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);

    if (_tts != null) {
      if (_tts!.isNotEmpty) {
        await _flutterTts.speak(_tts!);
      }
    }
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    }
  }

  Future<void> sendImageToApi(XFile imagePath) async {
  // Uint8List pngBytes = await convertXFileToPng(imagePath);
  // print(pngBytes.runtimeType);
  // String base64Img = base64Encode(pngBytes);
  final response = await http.post(
    Uri.parse('https://api.replicate.com/v1/predictions'),
    headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Token r8_BbVMkGSRAZWPnMwNA5vQaNuEmh5ZxTd0838JH',
    },
    body: jsonEncode({
    'version': '9109553e37d266369f2750e407ab95649c63eb8e13f13b1f3983ff0feb2f9ef7',
    'input': {'image': 'https://pbxt.replicate.delivery/IJEPJQ1Cx2l0TVdISAtGBATLGr0bn3sqZfOAY05QXepqDXd5/gg_bridge.jpeg'},
    }),
  );

    print(response.statusCode);
    if (response.statusCode == 201) {
      // Parse the response
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String outputText = responseData['id']; // Adjust based on actual API response structure

      // Test image function
      print("hello world3");
      print(outputText);
      await Future.delayed(const Duration(seconds: 1), (){});
      await fetchReplicateData(outputText);
      speak();
    } else {
      print('Failed to send image to API: ${response.statusCode}');
    }
  }

  Future<void> fetchReplicateData(String id) async {
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
        String response = responseData['output'];
        print(response);
        _tts = response;
      } else if(status == "failed"){
        print(responseData['logs']);
      } else {
        await Future.delayed(const Duration(seconds: 5), (){});
        fetchReplicateData(id);
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

}

