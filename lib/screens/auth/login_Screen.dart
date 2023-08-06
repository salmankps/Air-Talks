import 'dart:developer';
import 'dart:io';

import 'package:air_talks/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helpers/dialogues.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser:${user.user}');
        log('\nUserAdditionalInfo:${user.additionalUserInfo}');
        if((await APIs.userExists())){

      Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const HomePage()));
      }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          });
        }


      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle:$e');
      Dialogs.showSnackBar(context, 'Something went wrong(check internet!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            bottom: _isAnimate ? mq.width * .99 : -mq.width * .5,
            left: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png'),
          ),
          AnimatedPositioned(
            bottom: mq.height * .15,
            right: _isAnimate ? mq.width * .05 : -mq.width * .99,
            width: mq.width * .9,
            height: mq.height * .06,
            duration: const Duration(seconds: 1),
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 3,
              ),
              icon: Image.asset(
                "images/google.png",
                height: mq.height * .03,
              ),
              label: RichText(
                  text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: [
                    TextSpan(text: "Sign In with "),
                    TextSpan(
                        text: "Google",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ))
                  ])),
            ),
          ),
        ],
      ),
    );
  }
}
