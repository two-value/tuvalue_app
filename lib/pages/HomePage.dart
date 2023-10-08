import 'package:app/pages/AddItemsPage.dart';
import 'package:app/pages/CompanyUpdateProfile.dart';
import 'package:app/pages/EditPressesPage.dart';
import 'package:app/pages/EventsPage.dart';
import 'package:app/pages/FindingJobs.dart';
import 'package:app/pages/InterviewsPage.dart';
import 'package:app/pages/JobsPosted.dart';
import 'package:app/pages/JournalistUpdateProfilePage.dart';
import 'package:app/pages/JournalistsProfilePage.dart';
import 'package:app/pages/NewsPage.dart';
import 'package:app/pages/NotificationsPage.dart';
import 'package:app/pages/PitchesPage.dart';
import 'package:app/pages/PressesPage.dart';
import 'package:app/pages/PurchasePackage.dart';
import 'package:app/pages/ReportsPage.dart';
import 'package:app/pages/ShareAppPage.dart';
import 'package:app/pages/SupportPage.dart';
import 'package:app/pages/getting_started_screen.dart';
import 'package:app/services/profileData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'CompanyProfilePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bool isSignedIn = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  final usersReference = Firestore.instance.collection('Users');
  String _onlineUserId;
  int _bodyValue = 0;

  bool userFlag = false;
  var details;
  String _userType = 'not_set';

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _auth.currentUser();
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
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  Future _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => GettingStartedScreen(),
          ),
          (Route<dynamic> route) => false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Image(
          height: 24.0,
          image: AssetImage('assets/images/logo4.png'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(CupertinoIcons.bell_solid),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(),
                ),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            StreamBuilder(
                stream: Firestore.instance
                    .collection('Users')
                    .where('user_id', isEqualTo: _onlineUserId)
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
                      return UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                        accountName: Text('Loading...'),
                        currentAccountPicture: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.blueGrey,
                            size: 40,
                          ),
                        ),
                        accountEmail: null,
                      );
                    } else {
                      DocumentSnapshot userInfo = snapshot.data.documents[0];
                      return UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                        accountName: Text(
                          userInfo['user_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        currentAccountPicture: InkWell(
                          onTap: _userType == 'Company'
                              ? () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanyProfilePage(),
                                    ),
                                  );
                                }
                              : () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          JournalistsProfilePage(),
                                    ),
                                  );
                                },
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                NetworkImage(userInfo['user_image']),
                          ),
                        ),
                        accountEmail: null,
                      );
                    }
                  }
                }),
            ListTile(
              leading: Icon(CupertinoIcons.add_circled),
              title: Text('Adaugă'),
              onTap: () {
                setState(() {
                  _bodyValue = 7;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.book_solid),
              title: Text('Comunicate de presă'),
              onTap: () {
                setState(() {
                  _bodyValue = 0;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.time_solid),
              title: Text('Evenimente'),
              onTap: () {
                setState(() {
                  _bodyValue = 1;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.mic_solid),
              title: Text('Interviuri'),
              onTap: () {
                setState(() {
                  _bodyValue = 2;
                  Navigator.pop(context);
                });
              },
            ),

            ListTile(
              leading: Icon(CupertinoIcons.volume_up),
              title: Text('Caută un subiect'),
              onTap: () {
                setState(() {
                  _bodyValue = 6;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.collections_solid),
              title: Text('Oferte de job-uri'),
              onTap: () {
                setState(() {
                  _bodyValue = 4;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.search),
              title: Text('Caută job-uri'),
              onTap: () {
                setState(() {
                  _bodyValue = 5;
                  Navigator.pop(context);
                });
              },
            ),

//            Padding(
//              padding: const EdgeInsets.only(left: 16.0, top: 8),
//              child: Text('Subscriptions'),
//            ),
//            ListTile(
//              leading: Icon(CupertinoIcons.bookmark_solid),
//              title: Text('My Subscriptions'),
//              onTap: () {
//                Navigator.pop(context);
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => Packages(),
//                  ),
//                );
//              },
//            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              child: Text('Din 2value'),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.news_solid),
              title: Text('Știri'),
              onTap: () {
                setState(() {
                  _bodyValue = 3;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.tag_solid),
              title: Text('Articole'),
              onTap: () {
                setState(() {
                  _bodyValue = 3;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.circle_filled),
              title: Text('Reportajele mele'),
              onTap: () {
                setState(() {
                  _bodyValue = 10;
                  Navigator.pop(context);
                });
              },
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Text('Tasks'),
              ),
            ),
            Visibility(
              visible: false,
              child: ListTile(
                leading: Icon(CupertinoIcons.pen),
                title: Text('Edit press releases'),
                onTap: () {
                  setState(() {
                    _bodyValue = 11;
                    Navigator.pop(context);
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              child: Text('Acțiuni'),
            ),
//            ListTile(
//              leading: Icon(CupertinoIcons.share_up),
//              title: Text('Share 2value'),
//              onTap: () {
//                Navigator.pop(context);
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => ShareAppPage(),
//                  ),
//                );
//              },
//            ),
            ListTile(
              leading: Icon(CupertinoIcons.settings_solid),
              title: Text('Setările profilului'),
              onTap: _userType == 'Company'
                  ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyUpdateProfile(),
                        ),
                      );
                    }
                  : () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JournalistUpdateProfile(),
                        ),
                      );
                    },
            ),
            ListTile(
              leading: Icon(Icons.contact_phone),
              title: Text('Suport'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Deconectează-te'),
              onTap: () {
                _logOut();
              },
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
      body: (_bodyValue == 0)
          ? PressesPage()
          : (_bodyValue == 1)
              ? EventsPage()
              : (_bodyValue == 2)
                  ? InterviewsPage()
                  : (_bodyValue == 3)
                      ? NewsPage()
                      : (_bodyValue == 4)
                          ? JobsPosted()
                          : (_bodyValue == 5)
                              ? FindingJobs()
                              : (_bodyValue == 6)
                                  ? PitchesPage()
                                  : (_bodyValue == 10)
                                      ? ReportsPage()
                                      : (_bodyValue == 11)
                                          ? EditPressesPage()
                                          : (_bodyValue == 7)
                                              ? AddItemsPage()
                                              : PressesPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomeScreen();
  }
}
