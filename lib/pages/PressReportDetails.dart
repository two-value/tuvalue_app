import 'package:app/model/Avengers.dart';
import 'package:app/services/profileData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PressReportDetails extends StatefulWidget {
  final String posterId;
  final String postId;
  PressReportDetails({this.posterId, this.postId});

  @override
  _PressReportDetailsState createState() =>
      _PressReportDetailsState(posterId: posterId, postId: postId);
}

class _PressReportDetailsState extends State<PressReportDetails> {
  String posterId;
  String postId;
  _PressReportDetailsState({this.posterId, this.postId});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _onlineUserId;

  List<Avengers> avengers;
  List<Avengers> selectedAvengers;
  bool sort;

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
      appBar: AppBar(
        title: Text('Raport comunicat de presă'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('Presses')
              .orderBy('press_time', descending: true)
              .where('press_poster', isEqualTo: _onlineUserId)
              .limit(100)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              if (snapshot.data.documents.length == 0) {
                return Container();
              } else {
                return DataTable(
                  columns: [
                    DataColumn(
                      label: Text("Date"),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text("Views"),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text("Shares"),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text("Comments"),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text("Category"),
                      numeric: false,
                    ),
                  ],
                  rows: _createRows(snapshot.data),
                );
              }
            }
          },
        ),
      ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList =
        snapshot.documents.map((DocumentSnapshot documentSnapshot) {
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          // All rows will have the same selected color.
          // Even rows will have a grey color.
          if (documentSnapshot['press_id'] == postId)
            return Colors.grey.withOpacity(0.3);
          return null; // Use default value for other states and odd rows.
        }),
        cells: [
          DataCell(
            Text(
              documentSnapshot['press_id'].toString(),
              style: TextStyle(),
            ),
          ),
          DataCell(
            Text(
              documentSnapshot['press_read_count'].toString(),
            ),
          ),
          DataCell(
            Text(
              documentSnapshot['press_ratings'].toString(),
            ),
          ),
          DataCell(
            Text(
              documentSnapshot['comments_count'].toString(),
            ),
          ),
          DataCell(
            Text(
              documentSnapshot['press_category'].toString(),
            ),
          ),
        ],
      );
    }).toList();

    return newList;
  }
}
