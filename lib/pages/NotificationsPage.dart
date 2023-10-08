import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future _data;
  String _onlineUserId;

  Future _getUsers() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    _onlineUserId = user.uid;
    var _fireStore = Firestore.instance;
    QuerySnapshot qn = await _fireStore
        .collection('Notifications')
        .document('important')
        .collection(_onlineUserId)
        .getDocuments();
    return qn.documents;
  }

  @override
  void initState() {
    super.initState();
    _data = _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificări'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text('Loading...'),
              );
            } else {
              if (snapshot.data.length == 0) {
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
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return _displayCommentsInfo(index, snapshot);
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _displayCommentsInfo(index, commentSnapshot) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .where('user_id',
                isEqualTo:
                    commentSnapshot.data[index].data['notification_sender'])
            //.orderBy('comment_time'
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(child: Text('Loading...'));
          } else {
            if (snapshot.data.documents.length == 0) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.grey,
                ),
                title: Text('Comment owner not found.'),
                subtitle: Text(
                  TimeAgo.getTimeAgo(
                      commentSnapshot.data[index].data['notification_time']),
                ),
                dense: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              );
            } else {
              DocumentSnapshot userInfo = snapshot.data.documents[0];
              return ListTile(
                leading: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(userInfo['user_image']),
                ),
                title: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${userInfo['user_name']}: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${commentSnapshot.data[index].data['notification_details']}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
                subtitle: Text(
                  TimeAgo.getTimeAgo(
                      commentSnapshot.data[index].data['notification_time']),
                ),
                dense: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              );
            }
          }
        });
  }
}
