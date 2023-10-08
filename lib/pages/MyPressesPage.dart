import 'package:app/routes/ScaleRoute.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import 'PressDetailsPage.dart';

class MyPressesPage extends StatefulWidget {
  final String accountId;
  final String accountName;
  MyPressesPage({this.accountId, this.accountName});

  @override
  _MyPressesPageState createState() =>
      _MyPressesPageState(accountId: accountId, accountName: accountName);
}

class _MyPressesPageState extends State<MyPressesPage> {
  String accountId;
  String accountName;
  _MyPressesPageState({this.accountId, this.accountName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$accountName's Press releases",
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Presses')
            .orderBy('press_time', descending: true)
            .where('press_poster', isEqualTo: accountId)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                //height: 200.0,
                                child: AspectRatio(
                                  aspectRatio: 1.5 / 1,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Image(
                                      image: AssetImage(
                                          'assets/images/loading.jpg'),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      'Posted ' +
                                          TimeAgo.getTimeAgo(
                                              myPresses['press_time']),
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
                },
              );
            }
          }
        },
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
              CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blueGrey,
                backgroundImage: NetworkImage(userInfo['user_image']),
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
            ],
          );
        }
      },
    );
  }
}
