

// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:aeyes_3/Screens/DeepScanScreen.dart';
import 'package:aeyes_3/Screens/QuickScanScreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

//main decleration
class homeScreen extends StatefulWidget {
  const homeScreen({
    super.key,
    required this.camera,
  });

  // const homeScreen({ Key? key, required this.camera }) : super(key: key);

  final CameraDescription camera;

  @override
  State<homeScreen> createState() => _homeScreen();
}

class _homeScreen extends State<homeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: GlobalAppBar(),
      body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the app!'),
            ElevatedButton(
              child: Text(
                'Quick Scan',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuickScanScreen(camera: widget.camera,)),);
              },
            ),
            ElevatedButton(
              child: Text(
                'Deep Scan',
                style: TextStyle(fontSize: 24.0),
              ),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeepScanScreen(camera: widget.camera,)),);
              },
            ),
        ],)
      ,)
      
    
      
  
        // Center(child: 
      //     Text(
      //       'helo world',
      //       textAlign: TextAlign.center,
      //       overflow: TextOverflow.ellipsis,
      //       style: const TextStyle(fontWeight: FontWeight.bold),
      //     )
      //   ),
    );
  }

}