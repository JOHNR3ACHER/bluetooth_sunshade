import 'dart:async';

import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, navigateToDeviceScreen);
  }

  navigateToDeviceScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D47A1), //Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BlueSun",
              style: TextStyle(
                fontFamily:
                    'Kollektif', // Set the font family to Kollektif
                fontSize: 48, // Set the font size to 48
                color: Color(0xFFFFFFFF), // Set the font color to white (0xFFFFFFFF)
                fontWeight: FontWeight.w100, // Set the font weight to 10%
              ),
            ),
            Text(
<<<<<<< HEAD
              "Retractable Sunshade",
=======
              "Retractable System",
>>>>>>> c96281ba686fe2ae8682d27e880c92a6a3b9864f
              style: TextStyle(
                fontFamily: 'Kollektif',
                fontSize: 18,
                fontWeight: FontWeight.w100,
                color: Color(0xFFFFFFFF),
              ),
            )
          ],
        ),
      ),
    );
  }
}
