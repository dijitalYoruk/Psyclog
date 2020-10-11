import 'dart:async';
import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  WebServerService _service;
  bool isUserExist;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUserExist = false;
    navigateUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> navigateUser() async {
    try {
      // Web Service for Authentication
      _service = await WebServerService.getWebServerService();

      final String currentUserToken = await _service.getToken();

      if (currentUserToken != null) {
        String result = await _service.checkUserByCurrentToken();

        if (result == ServiceConstants.STATUS_SUCCESS_CODE.toString()) {
          isUserExist = true;
        } else {
          isUserExist = false;
        }
      } else {
        isUserExist = false;
      }
    } catch (e) {
      print(e);
    }

    if (isUserExist) {
      print("Navigating to Home Page...");
      // Page Transition Delay
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, ViewConstants.homeRoute);
    } else {
      print("Navigating to Welcome Page...");
      // Page Transition Delay
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, ViewConstants.welcomeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstants.myWhite,
      body: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.only(top: 25, bottom: 10),
            width: MediaQuery.of(context).size.width * 0.45,
            child: Image.asset(
              "assets/PSYCLOG_black_text.png",
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
