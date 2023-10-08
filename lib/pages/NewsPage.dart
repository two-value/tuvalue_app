import 'package:app/pages/JournalistPublicProfile.dart';
import 'package:app/pages/CompanyPublicProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _onlineUserId;

  _getUid() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    _onlineUserId = user.uid;
  }

  navigateToCompanyDetails(DocumentSnapshot user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyPublicProfilePage(
          user: user,
        ),
      ),
    );
  }

  navigateToJournalistDetails(DocumentSnapshot user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalistPublicProfile(
          user: user,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Image(
            image: AssetImage('assets/images/empty.png'),
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
