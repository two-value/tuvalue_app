import 'package:app/pages/PressReportDetails.dart';
import 'package:app/routes/ScaleRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _onlineUserId;

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _auth.currentUser();
          setState(() {
            _onlineUserId = user.uid;
          });
        }
      },
    );
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Presses')
            .orderBy('press_time', descending: true)
            .where('press_poster', isEqualTo: _onlineUserId)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: SpinKitPulse(
                  color: Colors.blue,
                  size: 100.0,
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
                  return pressItem(index, myPresses);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget pressItem(
    int index,
    DocumentSnapshot myPresses,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: 350,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        myPresses['press_title'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      ScaleRoute(
                        page: PressReportDetails(
                          posterId: myPresses['press_poster'],
                          postId: myPresses['press_id'],
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '${myPresses['press_body']}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            CupertinoIcons.time,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: new Text(
                            'Posted ' +
                                TimeAgo.getTimeAgo(myPresses['press_time']),
                            style: new TextStyle(fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: Icon(
                            CupertinoIcons.eye,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: new Text(
                            '${myPresses['press_read_count']} View(s)',
                            style: new TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            CupertinoIcons.share,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: new Text(
                            '${myPresses['press_ratings']} Share(s)',
                            style: new TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            CupertinoIcons.conversation_bubble,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: new Text(
                            '${myPresses['comments_count']} Comment(s)',
                            style: new TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      child: new Text(
                        "View on report",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          ScaleRoute(
                            page: PressReportDetails(
                              posterId: myPresses['press_poster'],
                              postId: myPresses['press_id'],
                            ),
                          ),
                        );
                      },
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
