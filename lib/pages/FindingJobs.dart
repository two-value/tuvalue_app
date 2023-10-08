import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FindingJobs extends StatefulWidget {
  @override
  _FindingJobsState createState() => _FindingJobsState();
}

class _FindingJobsState extends State<FindingJobs> {
  Future<void> _launched;

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Find_jobs')
            .orderBy('find_job_time_stamp', descending: false)
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
                  DocumentSnapshot seekers = snapshot.data.documents[index];
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0, top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${seekers['find_job_title']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //setCompanyName(myInterviews),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Posted ' +
                                TimeAgo.getTimeAgo(seekers['find_job_time']),
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                          Text(
                            '${seekers['find_job_about']}',
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: 100.0,
                                height: 32.0,
                                child: FlatButton(
                                  child: Text(
                                    'View CV',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.all(4),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _launched = _launchInBrowser(
                                          seekers['find_job_cv']);
                                    });
                                  },
                                ),
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
