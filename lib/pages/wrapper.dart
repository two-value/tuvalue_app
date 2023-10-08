import 'dart:async';
import 'package:app/pages/EmailVerificationPage.dart';
import 'package:app/pages/HomePage.dart';
import 'package:app/pages/getting_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../main.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String onlineUserId;
  String _controller;

  @override
  void initState() {
    super.initState();

    Future<FirebaseUser> getUser() async {
      return await _auth.currentUser();
    }

    getUser().then((user) async {
      if (user == null) {
        setState(() {
          _controller = 'out';
        });
      } else {
        final snapShot = await Firestore.instance
            .collection('Users')
            .document(user.uid)
            .get();
        if (snapShot.exists) {
          setState(() {
            _controller = 'home';
          });
        } else {
          setState(() {
            _controller = 'info';
          });
        }
      }
    });
    Timer(
      Duration(seconds: 3),
      () {
        print('done');
        if (_controller == 'out') {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => GettingStartedScreen(),
              ),
              (Route<dynamic> route) => false);
        } else if (_controller == 'info') {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => EmailVerificationPage(),
              ),
              (Route<dynamic> route) => false);
        } else if (_controller == 'home') {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (Route<dynamic> route) => false);
        } else if (_controller == null) {
          MyApp.restartApp(context);
        }
        ;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitPulse(
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
