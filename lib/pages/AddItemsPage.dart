import 'package:app/pages/AddEventPage.dart';
import 'package:app/pages/AddFindingJob.dart';
import 'package:app/pages/AddInterviewPage.dart';
import 'package:app/pages/AddJobPage.dart';
import 'package:app/pages/AddPitchPage.dart';
import 'package:app/pages/AddPressPage.dart';
import 'package:app/pages/FreePlanPage.dart';
import 'package:app/services/profileData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddItemsPage extends StatefulWidget {
  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _onlineUserId;
  bool userFlag = false;
  var details;
  String _userType = 'not_set';
  String _userPlan = 'null';

  @override
  void initState() {
    super.initState();

    getUser().then(
      (user) async {
        if (user != null) {
          final FirebaseUser user = await _auth.currentUser();
          _onlineUserId = user.uid;

          ProfileService()
              .getProfileInfo(_onlineUserId)
              .then((QuerySnapshot docs) {
            if (docs.documents.isNotEmpty) {
              setState(
                () {
                  userFlag = true;
                  details = docs.documents[0].data;
                  _userType = details['account_type'];
                  _userPlan = details['user_plan'];
                },
              );
            }
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                isThreeLine: false,
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/clouds/100/000000/cloud-network.png'),
                  ),
                ),
                title: Text('Postează un comunicat de presă'),
                subtitle: Text(
                    'Un comunicat de presă este o comunicare cu valoare de informație, ce conține declarații oficiale sau anunțuri.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPress(),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/color/48/000000/event-accepted-tentatively.png'),
                  ),
                ),
                title: Text('Postează un eveniment'),
                subtitle: Text(
                    'Definiția unui eveniment este ceva care va avea loc. Un exemplu de eveniment este o adunare de afaceri/socială sau o conferință/declarație de presă.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEvent(),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/clouds/100/000000/microphone.png'),
                  ),
                ),
                title: Text('Postează un interviu'),
                subtitle: Text(
                    'Un interviu este în esență o conversație structurată în care 2value adresează întrebări standard la care tu oferi răspunsuri cu valoare de știre.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddInterviewPage(),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/bubbles/50/000000/speaker.png'),
                  ),
                ),
                title: Text('Caută un subiect'),
                subtitle: Text(
                    '2value oferă o modalitate de a lansa un subiect de presă către un public numeros. Este un mod de a solicita experți și de a crea oportunități.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPitchPage(),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/clouds/100/000000/mailbox-promotion.png'),
                  ),
                ),
                title: Text('Postează un job'),
                subtitle: Text(
                    'O postare de job înseamnă publicarea unei oferte de locuri de muncă în cadrul aplicației 2value pentru a ocupa un post vacant. Spune-ne denumirea job-ului și abilitățile necesare, iar 2value o va posta pentru tine.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddJobPage(),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Image(
                    image: NetworkImage(
                        'https://img.icons8.com/clouds/100/000000/mail-advertising.png'),
                  ),
                ),
                title: Text('Găsește un job'),
                subtitle: Text(
                    'Cauți un job? Ești în locul potrivit. 2value te ajută să îți faci cunoscute abilitățile, iar angajatorii să te remarce cu ușurință.'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _userPlan != 'null'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreePlanPage(),
                          ),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFindingJob(),
                          ),
                        );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
