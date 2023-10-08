import 'package:app/animations/FadeAnimations.dart';
import 'package:app/pages/PressDetailsPage.dart';
import 'package:app/services/SubscriptionService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyPublicProfilePage extends StatefulWidget {
  final DocumentSnapshot user;
  CompanyPublicProfilePage({this.user});

  @override
  _CompanyPublicProfilePageState createState() =>
      _CompanyPublicProfilePageState();
}

class _CompanyPublicProfilePageState extends State<CompanyPublicProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final databaseReference = Firestore.instance;
  bool _subscribeVisible = false;
  bool _subscribedVisible = false;
  bool _sizedBoxVisible = true;
  String _onlineUserId;

  _getSubscriber() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    _onlineUserId = user.uid;

    SubscriptionService()
        .getSubscriptionInfo(_onlineUserId, widget.user.data['user_id'])
        .then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(() {
          _subscribeVisible = false;
          _subscribedVisible = true;
          _sizedBoxVisible = false;
        });
      } else {
        setState(() {
          _subscribeVisible = true;
          _subscribedVisible = false;
          _sizedBoxVisible = true;
        });
      }
    });
  }

  unsubscribe() {
    DocumentReference subscriptionRef = Firestore.instance
        .collection('Subscribers')
        .document('subscribed_users')
        .collection(widget.user.data['user_id'])
        .document(_onlineUserId);
    DocumentReference usersRef = Firestore.instance
        .collection('Users')
        .document(widget.user.data['user_id']);

    subscriptionRef.delete();
    usersRef.updateData({'subscriptions_count': FieldValue.increment(-1)});
    firebaseMessaging.unsubscribeFromTopic('TopicToListen');

    setState(() {
      _subscribeVisible = true;
      _subscribedVisible = false;
      _sizedBoxVisible = true;
    });
  }

  subscribe() {
    DocumentReference subscriptionRef = Firestore.instance
        .collection('Subscribers')
        .document('subscribed_users')
        .collection(widget.user.data['user_id'])
        .document(_onlineUserId);
    DocumentReference usersRef = Firestore.instance
        .collection('Users')
        .document(widget.user.data['user_id']);

    DocumentReference notificationsRef = Firestore.instance
        .collection('Notifications')
        .document('all_notifications')
        .collection(widget.user.data['user_id'])
        .document();

    subscriptionRef.setData({'subscriber_id': _onlineUserId});
    usersRef.updateData({'subscriptions_count': FieldValue.increment(1)});
    firebaseMessaging.subscribeToTopic(widget.user.data['user_id']);

    Map<String, dynamic> _notification = {
      'notification_body': 'has subscribed to your account.',
      'notification_type': 'subscription',
      'notification_poster': _onlineUserId,
      'notification_time_stamp': DateTime.now(),
      'notification_time': DateTime.now().millisecondsSinceEpoch,
      'notification_extra': 'extra',
    };

    notificationsRef.setData(_notification);

    setState(() {
      _subscribeVisible = false;
      _subscribedVisible = true;
      _sizedBoxVisible = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSubscriber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                expandedHeight: MediaQuery.of(context).size.width,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.user.data['user_image']),
                            fit: BoxFit.cover)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          colors: [Colors.black, Colors.black.withOpacity(.3)],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FadeAnimation(
                                1,
                                Text(
                                  widget.user.data['user_name'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 34),
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: <Widget>[
                                FadeAnimation(
                                    1.2,
                                    Text(
                                      '${widget.user.data['presses_count']} Posts',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    )),
                                SizedBox(
                                  width: 50,
                                ),
                                FadeAnimation(
                                    1.3,
                                    Text(
                                      "${widget.user.data['subscriptions_count']} Subscribers",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FadeAnimation(
                          1.6,
                          Text(
                            "About ${widget.user.data['user_name']}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                          1.6,
                          Text(
                            widget.user.data['about_user'],
                            style: TextStyle(height: 1.4),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        FadeAnimation(
                            1.6,
                            Text(
                              "Dynamic link",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                            1.6,
                            Text(
                              widget.user.data['external_link'],
                              style: TextStyle(color: Colors.deepOrange),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          1.6,
                          Text(
                            "${widget.user.data['user_name']}'s Press Releases",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          1.8,
                          StreamBuilder(
                            stream: Firestore.instance
                                .collection('Presses')
                                .orderBy('press_time', descending: true)
                                .where('press_poster',
                                    isEqualTo: widget.user.data['user_id'])
                                .limit(5)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text('Loading...');
                              } else {
                                if (snapshot.data.documents.length == 0) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/empty.png'),
                                        width: double.infinity,
                                      ),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot myPresses =
                                          snapshot.data.documents[index];

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 16.0),
                                        child: FlipCard(
                                          direction: FlipDirection
                                              .HORIZONTAL, // default
                                          front:
                                              makePressItem(index, myPresses),
                                          back:
                                              _backContainer(index, myPresses),
                                        ),
                                      );
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Visibility(
                          visible: _subscribedVisible,
                          child: FadeAnimation(
                            2,
                            GestureDetector(
                              onTap: () {
                                unsubscribe();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Align(
                                    child: Text(
                                  "Subscribed",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18.0,
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _sizedBoxVisible,
                          child: SizedBox(
                            height: 50,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  )
                ]),
              )
            ],
          ),
          Visibility(
            visible: _subscribeVisible,
            child: Positioned.fill(
              bottom: 50,
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeAnimation(
                    2,
                    GestureDetector(
                      onTap: () {
                        subscribe();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Align(
                            child: Text(
                          "Subscribe",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

//start
  Widget makePressItem(
    int index,
    DocumentSnapshot myPresses,
  ) {
    return AspectRatio(
      aspectRatio: 1.5 / 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            BoxShadow(
                color: Color(0xFF6078ea).withOpacity(.3),
                offset: Offset(0.0, 8.0),
                blurRadius: 8.0)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage('${myPresses['press_image']}'),
                    fit: BoxFit.cover)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(.3),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    myPresses['press_title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backContainer(int index, DocumentSnapshot myPresses) {
    return AspectRatio(
      aspectRatio: 1.5 / 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            BoxShadow(
                color: Color(0xFF6078ea).withOpacity(.3),
                offset: Offset(0.0, 8.0),
                blurRadius: 8.0)
          ],
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      myPresses['press_title'],
                      style: TextStyle(
                        fontSize: 18.0,
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
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Text(
                myPresses['press_formatted_date'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(.3),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${myPresses['press_body']}',
                    //overflow: TextOverflow.ellipsis,
                    //maxLines: null,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 40.0, right: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    color: Colors.teal,
                    child: Text(
                      'Read more',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PressDetails(
                            posterId: myPresses['press_poster'],
                            postId: myPresses['press_id'],
                          ),
                        ),
                      );

                      databaseReference
                          .collection('Press_data')
                          .document(myPresses['press_poster'])
                          .collection(myPresses['press_id'])
                          .document('1_total_views')
                          .updateData({
                        'total': FieldValue.increment(1),
                      });
                      print(MediaQuery.of(context).size.width);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
