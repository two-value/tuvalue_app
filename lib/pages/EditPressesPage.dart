import 'package:app/pages/CompanyPublicProfilePage.dart';
import 'package:app/pages/PressDetailsPage.dart';
import 'package:app/routes/ScaleRoute.dart';
import 'package:app/services/profileData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class EditPressesPage extends StatefulWidget {
  @override
  _EditPressesPageState createState() => _EditPressesPageState();
}

class _EditPressesPageState extends State<EditPressesPage> {
  final key = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  final _formattedYearMonth = new DateFormat('yyyy_MM');
  final _formattedMonth = new DateFormat('MMM');
  final _formattedYear = new DateFormat('yyyy');

  bool userFlag = false;
  String _onlineUserId;

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _firebaseAuth.currentUser();
          setState(() {
            _onlineUserId = user.uid;
          });
        }
      },
    );
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Presses')
            .orderBy('press_time', descending: true)
            .where('press_status', isEqualTo: 'null')
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Image(
                  image: AssetImage('assets/images/empty.png'),
                  width: double.infinity,
                ),
              ),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Image(
                    image: AssetImage('assets/images/empty.png'),
                    width: double.infinity,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot myPresses = snapshot.data.documents[index];
                  return _displayPresses(index, myPresses);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget _displayPresses(
    int index,
    DocumentSnapshot myPresses,
  ) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: myPresses['press_poster'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          DocumentSnapshot userInfo = snapshot.data.documents[0];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyPublicProfilePage(
                            user: userInfo,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(userInfo['user_image']),
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 40.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userInfo['user_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(userInfo['user_locality']),
                      ],
                    ),
                  ),
                ),

                //Text(userSnapshot['user_name']),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          key.currentState.showSnackBar(
                            new SnackBar(
                              content: new Text(userInfo['user_id']),
                            ),
                          );
                        },
                        child: Text(
                          myPresses['press_title'],
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            ScaleRoute(
                              page: PressDetails(
                                posterId: myPresses['press_poster'],
                                postId: myPresses['press_id'],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          myPresses['press_body'],
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
              ),
              ButtonBar(
                children: <Widget>[
                  myPresses['press_status'] == 'null' ||
                          myPresses['press_status'] == _onlineUserId
                      ? FlatButton(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: myPresses['press_status'] == _onlineUserId
                                ? Text(
                                    'Untake Task',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  )
                                : Text(
                                    'Take Task',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                          ),
                          onPressed: myPresses['press_status'] == _onlineUserId
                              ? () {
                                  databaseReference
                                      .collection('Presses')
                                      .document(myPresses['press_id'])
                                      .updateData({
                                    'press_status': 'null',
                                  });

                                  databaseReference
                                      .collection('Users')
                                      .document(_onlineUserId)
                                      .updateData({
                                    'user_extra': 'extra',
                                  });
                                }
                              : () {
                                  databaseReference
                                      .collection('Presses')
                                      .document(myPresses['press_id'])
                                      .updateData({
                                    'press_status': _onlineUserId,
                                  });

                                  databaseReference
                                      .collection('Users')
                                      .document(_onlineUserId)
                                      .updateData({
                                    'user_extra': myPresses['press_id'],
                                  });
                                },
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.green,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        )
                      : FlatButton(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Take Task',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          onPressed: null,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
