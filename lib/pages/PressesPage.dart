import 'package:app/pages/PressDetailsPage.dart';
import 'package:app/pages/CompanyProfilePage.dart';
import 'package:app/pages/CompanyPublicProfilePage.dart';
import 'package:app/routes/ScaleRoute.dart';
import 'package:app/services/profileData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:share/share.dart';

class PressesPage extends StatefulWidget {
  @override
  _PressesPageState createState() => _PressesPageState();
}

class _PressesPageState extends State<PressesPage> {
  final key = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  final _formattedYearMonth = new DateFormat('yyyy_MM');
  final _formattedMonth = new DateFormat('MMM');
  final _formattedYear = new DateFormat('yyyy');

  String _monthColor = '0xff2e7d32';

  setMonthColors() {
    if (_formattedMonth.format(DateTime.now()) == 'Jan') {
      setState(() {
        _monthColor = '0xff6a1b9a';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Feb') {
      setState(() {
        _monthColor = '0xff1565c0';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Mar') {
      setState(() {
        _monthColor = '0xff00695c';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Apr') {
      setState(() {
        _monthColor = '0xff558b2f';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'May') {
      setState(() {
        _monthColor = '0xff6a1b9a';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Jun') {
      setState(() {
        _monthColor = '0xff9e9d24';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Jul') {
      setState(() {
        _monthColor = '0xffff8f00';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Aug') {
      setState(() {
        _monthColor = '0xff4e342e';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Sept') {
      setState(() {
        _monthColor = '0xff757575';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Oct') {
      setState(() {
        _monthColor = '0xff37474f';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Nov') {
      setState(() {
        _monthColor = '0xffff5252';
      });
    }
    if (_formattedMonth.format(DateTime.now()) == 'Dec') {
      setState(() {
        _monthColor = '0xff880e4f';
      });
    }
  }

  _setUserInitialSharingData() async {
    final snapShot = await Firestore.instance
        .collection('Sharing_data')
        .document(_formattedYear.format(new DateTime.now()))
        .collection(_onlineUserId)
        .document(_formattedYearMonth.format(new DateTime.now()))
        .get();
    if (!snapShot.exists && _userType == 'Journalist') {
      try {
        databaseReference
            .collection('Sharing_data')
            .document(_formattedYear.format(new DateTime.now()))
            .collection(_onlineUserId)
            .document(_formattedYearMonth.format(new DateTime.now()))
            .setData({
          'color': _monthColor,
          'direct_shares': 0,
          'link_copies': 0,
          'month': _formattedMonth.format(new DateTime.now()),
          'total_shares': 0,
        });
      } catch (e) {
        print(e.toString());
      }
    }
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

  bool userFlag = false;
  var details;
  String _onlineUserId;
  String _userType = 'not_set';

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _firebaseAuth.currentUser();
          _onlineUserId = user.uid;

          ProfileService()
              .getProfileInfo(_onlineUserId)
              .then((QuerySnapshot docs) {
            if (docs.documents.isNotEmpty) {
              setState(
                () {
                  userFlag = true;
                  details = docs.documents[0].data;
                  _userType = details['account_type'];
                },
              );
            }
          });
        }
      },
    );

    setMonthColors();
    _setUserInitialSharingData();
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: key,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Presses')
            .orderBy('press_time', descending: true)
            .where('press_status', isEqualTo: 'Approved')
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
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 8.0,
                  top: 8.0,
                ),
                child: displayUserInfo(index, myPresses),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //height: 200.0,
                  child: AspectRatio(
                    aspectRatio: 1.5 / 1,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Image(
                        image: AssetImage('assets/images/loading.jpg'),
                      ),
                      imageUrl: '${myPresses['press_image']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
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
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
//                                  Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                      builder: (context) => PressDetails(
//                                        time: myPresses['press_time'],
//                                        posterId: myPresses['press_poster'],
//                                        postId: myPresses['press_id'],
//                                      ),
//                                    ),
//                                  );

                    Navigator.push(
                      context,
                      ScaleRoute(
                        page: PressDetails(
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

                    databaseReference
                        .collection('Presses')
                        .document(myPresses['press_id'])
                        .updateData({
                      'press_read_count': FieldValue.increment(1),
                    });
                  },
                  child: Text(
                    '${myPresses['press_body']}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 8,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        'Posted ' + TimeAgo.getTimeAgo(myPresses['press_time']),
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      '${myPresses['comments_count']} Comment(s)',
                      style: TextStyle(
                        color: Colors.grey,
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

  Widget displayUserInfo(
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
          return Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (userInfo['user_id'] == _onlineUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyProfilePage(),
                      ),
                    );
                  } else {
                    navigateToCompanyDetails(userInfo);
                  }
                },
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: NetworkImage(userInfo['user_image']),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Container(
                  color: Colors.black45,
                  height: 30,
                  width: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userInfo['user_name'],
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userInfo['user_locality'],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    )
                  ],
                ),
              ),
              Flexible(child: Container()),
              Container(
                height: 30,
                child: Center(child: popMenuButton(userInfo, myPresses)),
              )
            ],
          );
        }
      },
    );
  }

  Widget popMenuButton(DocumentSnapshot userInfo, DocumentSnapshot myPresses) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20.0,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '0',
          child: Text('Copy content'),
        ),
        PopupMenuItem<String>(
          value: '1',
          child: Text('Forward content'),
        ),
      ],
      onSelected: (retVal) {
        if (retVal == '0') {
          Clipboard.setData(ClipboardData(
              text:
                  'Company name: ${userInfo['user_name']} \nPress release title: ${myPresses['press_title']} \nPress release body: ${myPresses['press_body']} \nPress release image: ${myPresses['press_image']}'));
          key.currentState.showSnackBar(new SnackBar(
            content: new Text("Copied to Clipboard"),
          ));
          try {
            databaseReference
                .collection('Sharing_data')
                .document(_formattedYear.format(new DateTime.now()))
                .collection(_onlineUserId)
                .document(_formattedYearMonth.format(new DateTime.now()))
                .updateData({
              'direct_shares': 0,
              'link_copies': FieldValue.increment(1),
              'total_shares': FieldValue.increment(1),
            });

            databaseReference
                .collection('Press_data')
                .document(myPresses['press_poster'])
                .collection(myPresses['press_id'])
                .document('3_total_shares')
                .updateData({
              'total': FieldValue.increment(1),
            });

            databaseReference
                .collection('Presses')
                .document(myPresses['press_id'])
                .updateData({
              'press_ratings': FieldValue.increment(1),
            });
          } catch (e) {
            print(e.toString());
          }
        }
        if (retVal == '1') {
          Share.share(
            'Company name: ${userInfo['user_name']} \nPress release title: ${myPresses['press_title']} \nPress release body: ${myPresses['press_body']} \nPress release image: ${myPresses['press_image']}',
            subject: 'Fowarded Press release',
          );
          try {
            databaseReference
                .collection('Sharing_data')
                .document(_formattedYear.format(new DateTime.now()))
                .collection(_onlineUserId)
                .document(_formattedYearMonth.format(new DateTime.now()))
                .updateData({
              'direct_shares': 0,
              'link_copies': FieldValue.increment(1),
              'total_shares': FieldValue.increment(1),
            });

            databaseReference
                .collection('Press_data')
                .document(myPresses['press_poster'])
                .collection(myPresses['press_id'])
                .document('3_total_shares')
                .updateData({
              'total': FieldValue.increment(1),
            });

            databaseReference
                .collection('Presses')
                .document(myPresses['press_id'])
                .updateData({
              'press_ratings': FieldValue.increment(1),
            });
          } catch (e) {
            print(e.toString());
          }
        }
      },
    );
  }
}
