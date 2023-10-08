import 'package:app/pages/JobsEngagePage.dart';
import 'package:app/routes/ScaleRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class JobsPosted extends StatefulWidget {
  @override
  _JobsPostedState createState() => _JobsPostedState();
}

class _JobsPostedState extends State<JobsPosted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('New_jobs')
            .orderBy('posted_job_time', descending: false)
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
                  DocumentSnapshot myJobs = snapshot.data.documents[index];
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${myJobs['posted_job_title']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //setCompanyName(myInterviews),
                          SizedBox(
                            height: 4,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                ScaleRoute(
                                  page: JobsEngagePage(
                                    posterId: myJobs['posted_job_poster'],
                                    postId: myJobs['posted_job_id'],
                                    postSnapshot: myJobs,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '${myJobs['posted_job_description']}',
                              maxLines: 4,
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
                                      TimeAgo.getTimeAgo(
                                          myJobs['posted_job_time']),
                                  style: TextStyle(color: Colors.grey)),
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
