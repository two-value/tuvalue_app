import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  //DateTime _date = DateTime.now();
  String _onlineUserId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _firebaseAuth.currentUser();
          _onlineUserId = user.uid;
        }
      },
    );
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  DateTime selectedDate = DateTime(2019);

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2020),
      lastDate: DateTime(2022),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Events')
            .orderBy('event_time_stamp', descending: true)
            .where('event_time_stamp',
                isGreaterThan: selectedDate.millisecondsSinceEpoch)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Loading...'));
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
                  DocumentSnapshot myEvents = snapshot.data.documents[index];
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${myEvents['event_day']}",
                                style: TextStyle(
                                    fontSize: 14,
                                    //color: Color(0xfffe2c53),
                                    color: Colors.blueGrey),
                              ),
                              _controlStar(myEvents)
                            ],
                          ),
                          Text(
                            '${myEvents['event_title']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          setCompanyName(myEvents),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffedf1f7),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    CupertinoIcons.group,
                                    color: Color(0xff6a7182),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Status",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6a7182),
                                    ),
                                  ),
                                  Text(
                                    "${myEvents['interested_count']} Interested",
                                    style: TextStyle(
                                      color: Color(0xffb3bccb),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffedf1f7),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    CupertinoIcons.location,
                                    color: Color(0xff6a7182),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Locație",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff6a7182),
                                      ),
                                    ),
                                    Text(
                                      "${myEvents['event_venue']}",
                                      style: TextStyle(
                                        color: Color(0xffb3bccb),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Descriere',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${myEvents['event_description']}',
                            style: TextStyle(
                                //fontFamily: 'ArchivoNarrow',
                                ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          StreamBuilder(
                              stream: Firestore.instance
                                  .collection('Events')
                                  .orderBy('event_time_stamp',
                                      descending: false)
                                  .limit(100)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: Text('Loading...'));
                                } else {
                                  return _controlButton(myEvents);
                                }
                              }),
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 1.0,
                              color: Colors.black26.withOpacity(.2),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          _selectDate(context);
        },
        child: Icon(Icons.filter_list),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget setCompanyName(DocumentSnapshot myEvents) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: myEvents['event_poster'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          DocumentSnapshot userInfo = snapshot.data.documents[0];
          return Text(
            userInfo['user_name'],
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
      },
    );
  }

  Widget _controlButton(DocumentSnapshot myEvents) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Interested')
          .document("Events")
          .collection(myEvents["event_id"])
          .where('interested_user', isEqualTo: _onlineUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return ButtonTheme(
              minWidth: 200.0,
              height: 44.0,
              child: FlatButton(
                //color: Color(0xfffe2c53),
                color: Colors.blueGrey,
                onPressed: () {
                  controlButton(myEvents);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Interesat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                ),
              ),
            );
          } else {
            return ButtonTheme(
              minWidth: 200.0,
              height: 44.0,
              child: FlatButton(
                //color: Color(0xfffe2c53),
                color: Color(0xffedf1f7),
                onPressed: () {
                  controlButton(myEvents);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Neinteresat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _controlStar(DocumentSnapshot myEvents) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Interested')
          .document("Events")
          .collection(myEvents["event_id"])
          .where('interested_user', isEqualTo: _onlineUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return Icon(
              Icons.star_border,
              color: Colors.blueGrey,
            );
          } else {
            return Icon(
              Icons.star,
              color: Colors.blueGrey,
            );
          }
        }
      },
    );
  }

  void writeUserInterest(DocumentSnapshot myEvents) async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;

    DocumentReference _interestedRef = Firestore.instance
        .collection('Interested')
        .document("Events")
        .collection(myEvents["event_id"])
        .document(uid);
    Map<String, dynamic> _interest = {
      'interested_user': uid,
    };
    await _interestedRef.setData(_interest).whenComplete(() {
      DocumentReference interestCount = Firestore.instance
          .collection('Events')
          .document(myEvents["event_id"]);
      interestCount.updateData({'interested_count': FieldValue.increment(1)});
    });
  }

  void removeUserInterest(DocumentSnapshot myEvents) async {
    DocumentReference _interestedRef = Firestore.instance
        .collection('Interested')
        .document("Events")
        .collection(myEvents["event_id"])
        .document(_onlineUserId);

    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(_interestedRef).whenComplete(() {
        DocumentReference interestCount = Firestore.instance
            .collection('Events')
            .document(myEvents["event_id"]);
        interestCount
            .updateData({'interested_count': FieldValue.increment(-1)});
      });
    });
  }

  void controlButton(DocumentSnapshot myEvents) async {
    final snapShot = await Firestore.instance
        .collection('Interested')
        .document('Events')
        .collection(myEvents["event_id"])
        .document(_onlineUserId)
        .get();

    if (snapShot.exists) {
      setState(() {
        removeUserInterest(myEvents);
      });
    } else {
      setState(() {
        writeUserInterest(myEvents);
      });
    }
  }
}
