import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ApproveUsers extends StatefulWidget {
  @override
  _ApproveUsersState createState() => _ApproveUsersState();
}

class _ApproveUsersState extends State<ApproveUsers> {
  final databaseReference = Firestore.instance;

  deleteUser(DocumentSnapshot userSnapshot) {
    try {
      databaseReference
          .collection('Users')
          .document(userSnapshot['user_id'])
          .updateData({
        'user_verification': 'Deleted',
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _addDashboardData(DocumentSnapshot userSnapshot) {
    try {
      databaseReference
          .collection('Dashboard_data')
          .document('4_total_users')
          .updateData({
        'total': FieldValue.increment(1),
      });

      if (userSnapshot['account_type'] == 'Company') {
        try {
          databaseReference
              .collection('Dashboard_data')
              .document('3_total_companies')
              .updateData(
            {
              'total': FieldValue.increment(1),
            },
          );
        } catch (e) {
          print(e.toString());
        }
      } else {
        try {
          databaseReference
              .collection('Dashboard_data')
              .document('2_total_journalists')
              .updateData({
            'total': FieldValue.increment(1),
          });
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  approveUser(DocumentSnapshot userSnapshot) {
    try {
      databaseReference
          .collection('Users')
          .document(userSnapshot['user_id'])
          .updateData(
        {
          'user_verification': 'Approved',
        },
      );

      DocumentReference notificationsRef = Firestore.instance
          .collection('Notifications')
          .document('all_notifications')
          .collection(userSnapshot['user_id'])
          .document();

      Map<String, dynamic> _notification = {
        'notification_body':
            'Your 2value account has been approved. You now have access to your account features. Stay connected.',
        'notification_type': 'approval',
        'notification_poster': 'ZxZy_2value_admin_account',
        'notification_time_stamp': DateTime.now(),
        'notification_time': DateTime.now().millisecondsSinceEpoch,
        'notification_extra': 'extra',
      };

      notificationsRef.setData(_notification);
      _addDashboardData(userSnapshot);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _handleClickApprove(DocumentSnapshot userSnapshot) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Approve user'),
          content: Text('Are you sure you want to approve this user?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Allow'),
              onPressed: () {
                approveUser(userSnapshot);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleClickDelete(DocumentSnapshot userSnapshot) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete user'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Delete'),
              onPressed: () {
                deleteUser(userSnapshot);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve users'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        elevation: 8,
      ),
      body: Container(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('Users')
                .where('user_verification', isEqualTo: 'null')
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                      DocumentSnapshot userSnapshot =
                          snapshot.data.documents[index];

                      return Center(
                        child: Card(
                          margin: EdgeInsets.only(
                            left: 8.0,
                            top: 8.0,
                            right: 8.0,
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  child: CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage: CachedNetworkImageProvider(
                                      userSnapshot['user_image'],
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: userSnapshot['user_name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' | ' +
                                              userSnapshot['account_type'],
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '\n' + userSnapshot['user_phone'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                //Text(userSnapshot['user_name']),
                                subtitle: Text(
                                  userSnapshot['about_user'],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      'APPROVE',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    onPressed: () {
                                      _handleClickApprove(userSnapshot);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: Colors.redAccent[100],
                                      ),
                                    ),
                                    onPressed: () {
                                      _handleClickDelete(userSnapshot);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            }),
      ),
    );
  }
}
