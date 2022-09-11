import 'package:flutter/material.dart';
import 'package:iot_project_final/login_screen.dart';
import 'package:iot_project_final/res/color.dart' as COLOR_APP;
import 'package:iot_project_final/utils/cache.dart';

import 'home_screen.dart';
import './home_screen2.dart';
class SplashScreen extends StatefulWidget {

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Kiem tra trong share preferen neu co Key thi chuyen sang HomeScreen, neu ko co thi qua _goLoginScreen()
    Cache.instance.load().listen((event) {
      print("onData");
    }, onDone: () {
      print("onDone");
      // print(Cache.instance.key);
      if (Cache.instance.key != null && Cache.instance.key.isNotEmpty) {
        //  Cache.instance.clean().listen((event) { },onDone:/**/ (){
        //    print(" Delete key in share preference");
        //  });
        // print(Cache.instance.key);
        _goHomeScreen();
      } else {
        print("key is null");

        _goLoginScreen();
      }
    }, onError: (error) {
      print("OnError: ");
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text(
          "Welcome",
          style: TextStyle(
              color: COLOR_APP.primaryColor,
              fontSize: 38,
              fontWeight: FontWeight.bold),
        )),
      ),
    );
  }

  _goHomeScreen() {
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) =>  HomeScreen()),
    //     (route) => false);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) =>  HomeScreen2()),
            (route) => false);
  }

  _goLoginScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
        (route) => false);
  }
}
