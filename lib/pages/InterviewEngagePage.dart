import 'package:app/animations/FadeAnimations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InterviewEngagePage extends StatefulWidget {
  final String posterId;
  final String postId;
  final DocumentSnapshot postSnapshot;
  InterviewEngagePage({this.posterId, this.postId, this.postSnapshot});

  @override
  _InterviewEngagePageState createState() => _InterviewEngagePageState(
      posterId: posterId, postId: postId, postSnapshot: postSnapshot);
}

class _InterviewEngagePageState extends State<InterviewEngagePage> {
  String posterId;
  String postId;
  DocumentSnapshot postSnapshot;
  _InterviewEngagePageState({this.posterId, this.postId, this.postSnapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii despre interviu'),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              FadeAnimation(
                1,
                Text(
                  postSnapshot['interview_title'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FadeAnimation(
                1,
                postSnapshot['interview_image'] == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: AspectRatio(
                          aspectRatio: 1.5 / 1,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Image(
                                image: AssetImage('assets/images/loading.jpg')),
                            imageUrl: 'image',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: AspectRatio(
                          aspectRatio: 1.5 / 1,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Image(
                                image: AssetImage('assets/images/loading.jpg')),
                            imageUrl: postSnapshot['interview_image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FadeAnimation(
                1.1,
                Text(
                  'Cum ți-a venit ideea de afacere?',
                  style: TextStyle(
                    fontSize: 16,
                    //color: Colors.blueGrey,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              FadeAnimation(
                1.2,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueGrey[100],
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      postSnapshot['interview_idea'],
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FadeAnimation(
                1.1,
                Text(
                  'Cum ai dezvoltat afacerea/proiectul?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              FadeAnimation(
                1.2,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueGrey[100],
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      postSnapshot['interview_development'],
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FadeAnimation(
                1.2,
                Text(
                  'Cum ai finanțat afacerea/proiectul?',
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              FadeAnimation(
                1.2,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueGrey[100],
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      postSnapshot['interview_finance'],
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FadeAnimation(
                1.2,
                Text(
                  'Care sunt principalele provocări?',
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              FadeAnimation(
                1.2,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueGrey[100],
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      12.0,
                    ),
                    child: Text(
                      postSnapshot['interview_challenges'],
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FadeAnimation(
                1.2,
                Text(
                  'Care sunt previziunile de business?',
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              FadeAnimation(
                1.2,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueGrey[100],
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      postSnapshot['interview_plans'],
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
