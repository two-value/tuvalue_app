import 'package:app/animations/FadeAnimations.dart';
import 'package:app/model/PressChart.dart';
import 'package:app/pages/AdminDashboard.dart';
import 'package:app/pages/CompanyUpdateProfile.dart';
import 'package:app/pages/MyPressesPage.dart';
import 'package:app/pages/PressDetailsPage.dart';
import 'package:app/services/profileData.dart';
import 'package:app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CompanyProfilePage extends StatefulWidget {
  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool userFlag = false;
  var details;
  String onlineUserId;
  Future<void> _launched;

  @override
  void initState() {
    super.initState();

    getUser().then((user) async {
      if (user != null) {
        final FirebaseUser user = await _auth.currentUser();
        final uid = user.uid;

        ProfileService().getProfileInfo(uid).then((QuerySnapshot docs) {
          if (docs.documents.isNotEmpty) {
            setState(() {
              userFlag = true;
              details = docs.documents[0].data;
              onlineUserId = uid;
            });
          }
        });
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  List<charts.Series<PressData, String>> _seriesBarData;
  List<PressData> myData;
  _generateData(myData) {
    _seriesBarData = List<charts.Series<PressData, String>>();
    _seriesBarData.add(
      charts.Series(
          domainFn: (PressData info, _) => info.titleVal.toString(),
          measureFn: (PressData info, _) => info.totalVal,
          colorFn: (PressData shares, _) =>
              charts.ColorUtil.fromDartColor(Color(int.parse(shares.colorVal))),
          id: 'Info',
          data: myData,
          labelAccessorFn: (PressData row, _) => "${row.colorVal}"),
    );
  }

  Widget normalPopupMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 30.0,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '0',
          child: Text('Update profile'),
        ),
      ],
      onSelected: (retVal) {
        if (retVal == '0') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyUpdateProfile(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: userFlag
          ? StreamBuilder(
              stream: Firestore.instance
                  .collection('Users')
                  .where('user_id', isEqualTo: onlineUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text('Loading...'),
                  );
                } else {
                  DocumentSnapshot userInfo = snapshot.data.documents[0];
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        actions: <Widget>[
                          details['user_power'] == 'Admin'
                              ? IconButton(
                                  icon: Icon(Icons.person_pin),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminDashboard(),
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                          normalPopupMenuButton(),
                        ],
                        expandedHeight: MediaQuery.of(context).size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(userInfo['user_image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomRight,
                                  colors: [
                                    Colors.black,
                                    Colors.black.withOpacity(.3)
                                  ],
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
                                        userInfo['user_name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        FadeAnimation(
                                          1.2,
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyPressesPage(
                                                    accountId:
                                                        userInfo['user_id'],
                                                    accountName:
                                                        userInfo['user_name'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "${details['presses_count']} Press releases",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        FadeAnimation(
                                          1.3,
                                          Text(
                                            "${details['events_count']} Events",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                        ),
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
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FadeAnimation(
                                    1.6,
                                    Text(
                                      "About ${userInfo['user_name']} ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FadeAnimation(
                                    1.6,
                                    Text(
                                      userInfo['about_user'],
                                      style: TextStyle(height: 1.4),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  FadeAnimation(
                                      1.6,
                                      Text(
                                        "External link",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FadeAnimation(
                                      1.6,
                                      SelectableText(
                                        userInfo['external_link'],
                                        style:
                                            TextStyle(color: Colors.deepOrange),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FadeAnimation(
                                      1.6,
                                      Text(
                                        "My Press Releases",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FadeAnimation(
                                      1.8,
                                      Container(
                                        child: StreamBuilder(
                                            stream: Firestore.instance
                                                .collection('Presses')
                                                .orderBy('press_time',
                                                    descending: true)
                                                .where('press_poster',
                                                    isEqualTo: onlineUserId)
                                                .limit(5)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Text('Loading...');
                                              } else {
                                                if (snapshot.data.documents
                                                        .length ==
                                                    0) {
                                                  return Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: snapshot
                                                        .data.documents.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      DocumentSnapshot
                                                          myPresses = snapshot
                                                              .data
                                                              .documents[index];

                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 16.0),
                                                        child: FlipCard(
                                                          direction:
                                                              FlipDirection
                                                                  .HORIZONTAL,
                                                          // default
                                                          front: makePressItem(
                                                              index, myPresses),
                                                          back: _backContainer(
                                                              index, myPresses),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              }
                                            }),
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FadeAnimation(
                                    2,
                                    InkWell(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Align(
                                          child: Text(
                                            "Update Profile",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CompanyUpdateProfile(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
              })
          : Loading(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                child: makeChartItem(context, myPresses),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    color: Colors.teal,
                    child: Text(
                      'View post',
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

  Widget makeChartItem(BuildContext context, DocumentSnapshot myPresses) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Press_data')
          .document(onlineUserId)
          .collection(myPresses['press_id'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          List<PressData> shares = snapshot.data.documents
              .map((documentSnapshot) =>
                  PressData.fromMap(documentSnapshot.data))
              .toList();
          return buildChart(context, shares);
        }
      },
    );
  }

  Widget buildChart(BuildContext context, List<PressData> shares) {
    myData = shares;
    _generateData(myData);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              //Text('2value usage data'),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData,
                  animate: true,
                  vertical: true,
                  animationDuration: Duration(
                    seconds: 4,
                  ),
                  behaviors: [
                    charts.DatumLegend(
                      outsideJustification: charts.OutsideJustification.middle,
                      horizontalFirst: true,
                      desiredMaxRows: 2,
                      entryTextStyle: charts.TextStyleSpec(
                        //overflow: TextOverflow.ellipsis,
                        color: charts.MaterialPalette.purple.shadeDefault,
                        fontFamily: 'Georgia',
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
