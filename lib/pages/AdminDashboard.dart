import 'package:app/model/DashboardChart.dart';
import 'package:app/pages/ApproveUsers.dart';
import 'package:app/services/DashboardNumbers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final databaseReference = Firestore.instance;

  List<charts.Series<DashboardData, String>> _seriesBarData;
  List<DashboardData> myData;
  _generateData(myData) {
    _seriesBarData = List<charts.Series<DashboardData, String>>();
    _seriesBarData.add(
      charts.Series(
          domainFn: (DashboardData info, _) => info.titleVal.toString(),
          measureFn: (DashboardData info, _) => info.totalVal,
          colorFn: (DashboardData shares, _) =>
              charts.ColorUtil.fromDartColor(Color(int.parse(shares.colorVal))),
          id: 'Info',
          data: myData,
          labelAccessorFn: (DashboardData row, _) => "${row.colorVal}"),
    );
  }

  String totalUsers = '0';
  String totalJournalists = '0';
  String totalCompanies = '0';
  String newUsers = '0';

  _getTotalUsers() async {
    DashboardService().getDashInfo('Total').then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(
          () {
            totalUsers = docs.documents[0].data['total'].toString();
          },
        );
      }
    });
  }

  _getTotalJournalists() async {
    DashboardService().getDashInfo('Journalists').then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(
          () {
            totalJournalists = docs.documents[0].data['total'].toString();
          },
        );
      }
    });
  }

  _getTotalCompanies() async {
    DashboardService().getDashInfo('Companies').then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(
          () {
            totalCompanies = docs.documents[0].data['total'].toString();
          },
        );
      }
    });
  }

  _getNewUsers() async {
    QuerySnapshot newUsersQuery = await Firestore.instance
        .collection('Users')
        .where('user_verification', isEqualTo: 'null')
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = newUsersQuery.documents;
    setState(() {
      newUsers = _myDocCount.length.toString();
    });
  }

  @override
  void initState() {
    super.initState();

    _getTotalUsers();
    _getTotalJournalists();
    _getTotalCompanies();
    _getNewUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        elevation: 8.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Column(
            children: <Widget>[
              Container(
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 32.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total users',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            Text(
                              totalUsers,
                              style: TextStyle(
                                  fontSize: 32.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            CupertinoIcons.group_solid,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {},
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
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 32.0, 32.0, 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 30.0,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  child: Text(
                                    totalJournalists,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Journalists',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        onTap: () {},
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
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 32.0, 32.0, 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 30.0,
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.brown,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 32.0,
                                  ),
                                  child: Text(
                                    totalCompanies,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Companies',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                //height: MediaQuery.of(context).size.width / 2,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 32.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Live data'),
                      Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width / 2,
                        child: makeChartItem(context),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApproveUsers(),
                    ),
                  );
                },
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 32.0, 32.0, 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'New users',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.redAccent,
                                ),
                              ),
                              Text(
                                newUsers,
                                style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.supervised_user_circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeChartItem(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Dashboard_data').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          List<DashboardData> shares = snapshot.data.documents
              .map((documentSnapshot) =>
                  DashboardData.fromMap(documentSnapshot.data))
              .toList();
          return buildChart(context, shares);
        }
      },
    );
  }

  Widget buildChart(BuildContext context, List<DashboardData> shares) {
    myData = shares;
    _generateData(myData);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text('2value usage data'),
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

  Widget _loadScreenTwo() {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.add),
          title: Text("Add product"),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.change_history),
          title: Text("Products list"),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add_circle),
          title: Text("Add category"),
          onTap: () {
            //_categoryAlert();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.category),
          title: Text("Category list"),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add brand"),
          onTap: () {
            //_brandAlert();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.library_books),
          title: Text("brand list"),
          onTap: () {},
        ),
        Divider(),
      ],
    );
  }
}
