import 'package:app/animations/FadeAnimations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PitchEngagePage extends StatefulWidget {
  final String posterId;
  final String postId;
  final DocumentSnapshot postSnapshot;
  PitchEngagePage({this.posterId, this.postId, this.postSnapshot});

  @override
  _PitchEngagePageState createState() => _PitchEngagePageState(
      posterId: posterId, postId: postId, postSnapshot: postSnapshot);
}

class _PitchEngagePageState extends State<PitchEngagePage> {
  String posterId;
  String postId;
  DocumentSnapshot postSnapshot;
  _PitchEngagePageState({this.posterId, this.postId, this.postSnapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caută un subiect'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: _previewWidget(),
    );
  }

  Widget _previewWidget() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            FadeAnimation(
              1,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  postSnapshot['pitch_title'].toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            FadeAnimation(
              1.2,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  postSnapshot['pitch_body'],
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            FadeAnimation(
              1.2,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  postSnapshot['about_company'],
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
