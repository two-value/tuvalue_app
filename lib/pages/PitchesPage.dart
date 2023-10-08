import 'package:app/pages/PitchEngage.dart';
import 'package:app/routes/ScaleRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class PitchesPage extends StatefulWidget {
  @override
  _PitchesPageState createState() => _PitchesPageState();
}

class _PitchesPageState extends State<PitchesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Pitches')
            .orderBy('pitch_time', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Loading...'));
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
                  DocumentSnapshot pitches = snapshot.data.documents[index];
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${pitches['pitch_title']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //setCompanyName(myInterviews),
                          SizedBox(
                            height: 4.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                ScaleRoute(
                                  page: PitchEngagePage(
                                    posterId: pitches['pitch_poster'],
                                    postId: pitches['pitch_id'],
                                    postSnapshot: pitches,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '${pitches['pitch_body']}',
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Posted ' +
                                    TimeAgo.getTimeAgo(pitches['pitch_time']),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
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
}
