import 'package:app/animations/FadeAnimations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:app/model/Shares.dart';
import 'package:intl/intl.dart';

class JournalistPublicProfile extends StatefulWidget {
  final DocumentSnapshot user;
  JournalistPublicProfile({this.user});

  @override
  _JournalistPublicProfileState createState() =>
      _JournalistPublicProfileState();
}

class _JournalistPublicProfileState extends State<JournalistPublicProfile> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final _formattedYear = new DateFormat('yyyy');

  String _visitedUserId;

  _getIds() async {
    _visitedUserId = widget.user.data['user_id'];
  }

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
    // TODO: implement initState
    super.initState();
    _getIds();
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
                                  widget.user.data['user_name'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 34),
                                )),
                            SizedBox(
                              height: 20,
                            ),
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
                            "Despre ${widget.user.data['user_name']}",
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
                              "Link extern",
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
                              "${widget.user.data['user_name']}'s performanțe",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                          height: 60,
                        ),
                      ],
                    ),
                  )
                ]),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget makeChartItem(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Sharing_data')
          .document(_formattedYear.format(new DateTime.now()))
          .collection(_visitedUserId)
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
              Text('Preluări/lună'),
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
