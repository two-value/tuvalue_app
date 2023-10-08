import 'package:app/animations/FadeAnimations.dart';
import 'package:app/services/PressService.dart';
import 'package:app/services/profileData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PressDetails extends StatefulWidget {
  final String posterId;
  final String postId;
  PressDetails({this.posterId, this.postId});

  @override
  _PressDetailsState createState() =>
      _PressDetailsState(posterId: posterId, postId: postId);
}

class _PressDetailsState extends State<PressDetails> {
  int time;
  String posterId;
  String postId;
  _PressDetailsState({this.time, this.posterId, this.postId});
  final databaseReference = Firestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'iLnmTe5Q2Qw',
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: true,
    ),
  );

  final _formattedYearMonth = new DateFormat('yyyy_MM');
  final _formattedYear = new DateFormat('yyyy');

  bool userFlag = false;
  var postDetails;
  var onlineDetails;
  var visitedUserDetails;
  String _onlineUserId;

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _firebaseAuth.currentUser();
          _onlineUserId = user.uid;

          ProfileService()
              .getProfileInfo(_onlineUserId)
              .then((QuerySnapshot docs) {
            if (docs.documents.isNotEmpty) {
              setState(
                () {
                  onlineDetails = docs.documents[0].data;
                },
              );
              getVisitedData();
            }
          });
        }
      },
    );
  }

  getVisitedData() {
    ProfileService().getProfileInfo(posterId).then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(
          () {
            visitedUserDetails = docs.documents[0].data;
          },
        );
        getPostData();
      }
    });
  }

  getPostData() {
    PressDetailsService().getPressInfo(postId).then((QuerySnapshot docs) {
      if (docs.documents.isNotEmpty) {
        setState(() {
          userFlag = true;
          postDetails = docs.documents[0].data;
        });
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  Future _getComments() async {
    var _fireStore = Firestore.instance;
    QuerySnapshot qn = await _fireStore
        .collection('Comments')
        .document('presses_comments')
        .collection(postId)
        .orderBy('comment_time', descending: true)
        .getDocuments();
    return qn.documents;
  }

  TextEditingController textEditingController = new TextEditingController();

  void addNewMessage() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;

    if (textEditingController.text.trim().isNotEmpty) {
      DocumentReference pressRef =
          Firestore.instance.collection('Presses').document(postId);

      pressRef.updateData({'comments_count': FieldValue.increment(1)});

      CollectionReference ds = Firestore.instance
          .collection('Comments')
          .document('presses_comments')
          .collection(postId);
      Map<String, dynamic> _tasks = {
        'comment_body': textEditingController.text.trim(),
        'comment_poster': uid,
        'comment_time_stamp': DateTime.now(),
        'comment_time': DateTime.now().millisecondsSinceEpoch,
        'comment_extra': 'extra',
      };
      ds.add(_tasks).whenComplete(() {
        addCommentData();
        print('Press created');
        setState(() {
          //loading = false;
          //Navigator.pop(context);
          textEditingController.text = '';
        });
      });
    }
  }

  var top = 0.0;

  addCommentData() {
    databaseReference
        .collection('Press_data')
        .document(posterId)
        .collection(postId)
        .document('2_total_comments')
        .updateData({
      'total': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedCrossFade(
        firstChild: CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {},
              ),
              expandedHeight: MediaQuery.of(context).size.width * 2 / 3,
              backgroundColor: Colors.blue,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Container(height: 1200.0, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
        secondChild: userFlag
            ? Stack(
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
                        centerTitle: true,
                        actions: <Widget>[
                          onlineDetails['account_type'] == 'Journalist' &&
                                  onlineDetails['user_verification'] ==
                                      'Approved'
                              ? IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    Share.share(
                                      'Company name: ${visitedUserDetails['user_name']} \nPress release title: ${postDetails['press_title']} \nPress release body: ${postDetails['press_body']} \nPress release image: ${postDetails['press_image']}',
                                      subject: 'Fowarded Press release',
                                    );
                                    try {
                                      databaseReference
                                          .collection('Sharing_data')
                                          .document(_formattedYear
                                              .format(new DateTime.now()))
                                          .collection(_onlineUserId)
                                          .document(_formattedYearMonth
                                              .format(new DateTime.now()))
                                          .updateData({
                                        'direct_shares': 0,
                                        'link_copies': FieldValue.increment(1),
                                        'total_shares': FieldValue.increment(1),
                                      });

                                      databaseReference
                                          .collection('Press_data')
                                          .document(posterId)
                                          .collection(postId)
                                          .document('3_total_shares')
                                          .updateData({
                                        'total': FieldValue.increment(1),
                                      });
                                    } catch (e) {
                                      print(e.toString());
                                    }
                                  })
                              : Container(),
                        ],
                        expandedHeight:
                            MediaQuery.of(context).size.width * 2 / 3,
                        backgroundColor: Theme.of(context).primaryColor,
                        pinned: true,
                        floating: false,
                        flexibleSpace: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            top = constraints.biggest.height;
                            return FlexibleSpaceBar(
                              title: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: top < 120.0 ? 1.0 : 0.0,
                                child: displayUserInfo(),
                              ),
                              centerTitle: true,
                              collapseMode: CollapseMode.pin,
                              background: CachedNetworkImage(
                                placeholder: (context, url) => Image(
                                    image: AssetImage(
                                        'assets/images/loading.jpg')),
                                imageUrl: '${postDetails['press_image']}',
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FadeAnimation(
                                    1,
                                    Text(
                                      postDetails['press_title'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  FadeAnimation(
                                    1.1,
                                    Text(
                                      postDetails['press_formatted_date'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  FadeAnimation(
                                    1.2,
                                    Text(
                                      postDetails['press_summary'],
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
//                                  SizedBox(
//                                    height: 4.0,
//                                  ),
//                                  YoutubePlayer(
//                                    controller: _controller,
//                                    liveUIColor: Colors.amber,
//                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  FadeAnimation(
                                    1.2,
                                    Text(
                                      postDetails['press_body'],
                                      style: TextStyle(
                                        height: 1.4,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  FadeAnimation(
                                    1.2,
                                    Text(
                                      postDetails['about_company'],
                                      style: TextStyle(
                                        height: 1.4,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FadeAnimation(
                                    1.6,
                                    Text(
                                      '${postDetails['comments_count']} Comment(s)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  FadeAnimation(
                                    1.6,
                                    Container(
                                      child: FutureBuilder(
                                        future: _getComments(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: Text('Loading...'),
                                            );
                                          } else {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return _displayCommentsInfo(
                                                    index, snapshot);
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Visibility(
                    visible: false,
                    child: Positioned.fill(
                      bottom: 0,
                      child: Container(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FadeAnimation(
                            2,
                            Container(
                                //height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius:
                                          20.0, // has the effect of softening the shadow
                                      spreadRadius:
                                          5.0, // has the effect of extending the shadow
                                      offset: Offset(
                                        10.0, // horizontal, move right 10
                                        10.0, // vertical, move down 10
                                      ),
                                    )
                                  ],
                                ),
                                child: buildMessageTextField()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
        crossFadeState:
            userFlag ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget displayUserInfo() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Users')
          .where('user_id', isEqualTo: postDetails['press_poster'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Text(
              'Loading...',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white30,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          DocumentSnapshot userInfo = snapshot.data.documents[0];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              userInfo['user_name'],
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      },
    );
  }

  Widget _displayCommentsInfo(index, commentSnapshot) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Users')
          .where('user_id',
              isEqualTo: commentSnapshot.data[index].data['comment_poster'])
          //.orderBy('comment_time'
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading...');
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
                    text: '${commentSnapshot.data[index].data['comment_body']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            subtitle: Text(
              'Commented ' +
                  TimeAgo.getTimeAgo(
                      commentSnapshot.data[index].data['comment_time']),
            ),
            dense: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          );
        }
      },
    );
  }

  Widget buildMessageTextField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10, right: 8.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              controller: textEditingController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(15.0),
                hintText: 'Write your comment...',
                hintStyle: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xffAEA4A3),
                ),
              ),
              textInputAction: TextInputAction.send,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: 4.0,
          ),
          child: Container(
            width: 50.0,
            height: 50.0,
            child: Center(
              child: InkWell(
                onTap: addNewMessage,
                child: Icon(
                  Icons.send,
                  size: 24.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
