import 'package:app/animations/FadeAnimations.dart';
import 'package:app/services/profileData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JobsEngagePage extends StatefulWidget {
  final String posterId;
  final String postId;
  final DocumentSnapshot postSnapshot;
  JobsEngagePage({this.posterId, this.postId, this.postSnapshot});

  @override
  _JobsEngagePageState createState() => _JobsEngagePageState(
      posterId: posterId, postId: postId, postSnapshot: postSnapshot);
}

class _JobsEngagePageState extends State<JobsEngagePage> {
  String posterId;
  String postId;
  DocumentSnapshot postSnapshot;
  _JobsEngagePageState({this.posterId, this.postId, this.postSnapshot});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool userFlag = false;
  var details;

  @override
  void initState() {
    super.initState();

    ProfileService().getProfileInfo(posterId).then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(
          () {
            userFlag = true;
            details = docs.documents[0].data;
          },
        );
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii job'),
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
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            FadeAnimation(
              1,
              userFlag
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(details['user_image']),
                    )
                  : CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
            ),
            SizedBox(
              height: 8.0,
            ),
            FadeAnimation(
              1.1,
              userFlag
                  ? Text(
                      details['user_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : Text(
                      'Loading...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            SizedBox(
              height: 20.0,
            ),
            FadeAnimation(
              1.1,
              Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF000000).withOpacity(.3),
                          offset: Offset(0.0, 8.0),
                          blurRadius: 20.0)
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Description:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Text(
                          postSnapshot['posted_job_description'],
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 20.0,
            ),
            FadeAnimation(
              1.1,
              Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF000000).withOpacity(.3),
                          offset: Offset(0.0, 8.0),
                          blurRadius: 20.0)
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Requirements:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Text(
                          postSnapshot['posted_job_requirements'],
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 10.0,
            ),
            FadeAnimation(
              1.1,
              Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF000000).withOpacity(.3),
                          offset: Offset(0.0, 8.0),
                          blurRadius: 20.0)
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Contacts:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Text(
                          postSnapshot['posted_job_contacts'],
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
