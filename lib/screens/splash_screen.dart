import 'dart:developer';

import 'package:air_talks/api/apis.dart';
import 'package:air_talks/screens/auth/login_Screen.dart';
import 'package:air_talks/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black12,statusBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        log('\nUser:${APIs.auth.currentUser}');
        log('\nUserAdditionalInfo:${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .15,
            left: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('images/icon.png'),
          ),
          Positioned(
              bottom: mq.height * .15,
              right: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: const Text(
                "Welcome to Air Talks",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
}
