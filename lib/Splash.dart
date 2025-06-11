import 'dart:async';
import 'package:flutter/material.dart';
import 'package:git_barcode/common/database_helper.dart';
import 'BottomNavigationBar.dart';
import 'common/DbFunctions.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    DbFunctions().loadToken(); // Load token when app starts
    //_testDatabase();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/image/logo.png',
            height: MediaQuery.of(context).size.height *
                0.2, // Adjusting size to 30% of screen height
            fit: BoxFit
                .contain, // Ensures the image fits within the given height
          ),
        ));
  }
}
