import 'package:app/animations/FadeAnimations.dart';
import 'package:app/pages/JournalistUpdateProfilePage.dart';
import 'package:app/services/profileData.dart';
import 'package:app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:app/model/Shares.dart';
import 'package:intl/intl.dart';

class JournalistsProfilePage extends StatefulWidget {
  @override
  _JournalistsProfilePageState createState() => _JournalistsProfilePageState();
}

class _JournalistsProfilePageState extends State<JournalistsProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formattedYear = new DateFormat('yyyy');
  bool userFlag = false;
  var details;
  String onlineUserId;

  List<charts.Series<Shares, String>> _seriesBarData;
  List<Shares> myData;
  _generateData(myData) {
    _seriesBarData = List<charts.Series<Shares, String>>();
    _seriesBarData.add(
      charts.Series(
          domainFn: (Shares shares, _) => shares.shareMonth.toString(),
          measureFn: (Shares shares, _) => shares.shareVal,
          colorFn: (Shares shares, _) =>
              charts.ColorUtil.fromDartColor(Color(int.parse(shares.colorVal))),
          id: 'Shares',
          data: myData,
          labelAccessorFn: (Shares row, _) => "${row.shareMonth}"),
    );
  }

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
                                  ])),
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
                                            fontSize: 34,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    FadeAnimation(
                                      1.2,
                                      Text(
                                        'E-mail: ' + details['user_email'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
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
                                      "Despre ${userInfo['user_name']} ",
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
                                        "Link extern",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FadeAnimation(
                                      1.6,
                                      Text(
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
                                        "Performanțe mele jurnalistice",
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
                                      height: MediaQuery.of(context).size.width,
                                      child: makeChartItem(context),
                                    ),
                                  ),
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
                                            "Actualizează profilul",
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
                                                JournalistUpdateProfile(),
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
  Widget makeChartItem(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Sharing_data')
          .document(_formattedYear.format(new DateTime.now()))
          .collection(onlineUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          List<Shares> shares = snapshot.data.documents
              .map((documentSnapshot) => Shares.fromMap(documentSnapshot.data))
              .toList();
          return buildChart(context, shares);
        }
      },
    );
  }

  Widget buildChart(BuildContext context, List<Shares> shares) {
    myData = shares;
    _generateData(myData);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text('Shares by month'),
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
                      entryTextStyle: charts.TextStyleSpec(
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
