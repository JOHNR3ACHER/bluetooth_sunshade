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
      backgroundColor: Color(0xFF4C748B), //Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "POST",
              style: TextStyle(
                fontFamily: 'Norwester', // Set the font family to Norwester
                fontSize: 48, // Set the font size to 48
                color: Color(
                    0xFFFFFFFF), // Set the font color to white (0xFFFFFFFF)
                fontWeight: FontWeight.w100, // Set the font weight to 10%
              ),
            ),
            Text(
              "Extra security for your packages",
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
