import 'package:app/pages/SetupCompanyAccountPage.dart';
import 'package:app/pages/SetupJournalistAccountPage.dart';
import 'package:app/pages/getting_started_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _emailVerified = false;
  String _userEmail = 'null';
  ProgressDialog pr;

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  @override
  void initState() {
    super.initState();

    getUser().then((user) async {
      if (user == null) {
        setState(() {
          pushUserOut();
        });
      } else {
        setState(() {
          _userEmail = user.email;
        });
        //user.reload();
      }
    });
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: 60,
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  Future _sendVerificationEmail() async {
    var user = await _firebaseAuth.currentUser();
    try {
      await user.sendEmailVerification().then((value) {
        pr.hide();
      });

      print('email sent');
      return user.uid;
    } catch (e) {
      print(e.message);
    }
  }

  _reloadUser() async {
    var user = await _firebaseAuth.currentUser();
    user.reload().then((value) {
      pr.hide();
    });
    if (user.isEmailVerified) {
      setState(
        () {
          _emailVerified = true;
          print('email verified');
        },
      );
    } else {
      setState(() {
        _emailVerified = false;
        print('Email not verified');
      });
    }
  }

  pushUserOut() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => GettingStartedScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Se încarcă...');

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 10.0, top: 40.0, right: 10.0),
                      child: Image.asset("assets/images/verify_image.png"),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset(
                "assets/images/verify_bg.png",
                width: MediaQuery.of(context).size.width,
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 28.0,
                right: 28.0,
                bottom: 28.0,
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 180,
                  ),
                  form(),
                  SizedBox(height: 40),
                  Visibility(
                    visible: _emailVerified,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetupCompanyAccount(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(6.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color(0xFF6078ea).withOpacity(.3),
                                        offset: Offset(0.0, 8.0),
                                        blurRadius: 8.0)
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Companie",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SetupJournalistAccount(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color(0xFF6078ea).withOpacity(.3),
                                        offset: Offset(0.0, 8.0),
                                        blurRadius: 8.0)
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Jurnalist",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      horizontalLine(),
                      Text("Detalii cont",
                          style: TextStyle(
                            fontSize: 16.0,
                          )),
                      horizontalLine()
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Adresa $_userEmail nu este adresa ta de e-mail?'),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      await _firebaseAuth.signOut().then(
                        (res) {
                          pushUserOut();
                        },
                      );
                    },
                    child: Text("Deconectează-te",
                        style: TextStyle(
                            color: Color(0xFF5d74e3),
                            fontFamily: "Poppins-Bold")),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget form() {
    return _emailVerified
        ? Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 15.0),
                      blurRadius: 15.0),
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, -10.0),
                      blurRadius: 10.0),
                ]),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Felicitări!\nE-mailul tău e verificat.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'E-mailul ',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: '$_userEmail',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' a fost verificat cu succes. Acum poți continua cu configurarea contului tău 2value. '
                              'Dacă ești eligibil, fă clic pe unul '
                              'dintre butoanele de mai jos pentru a finaliza configurarea contului.',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 15.0),
                      blurRadius: 15.0),
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, -10.0),
                      blurRadius: 10.0),
                ]),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Verifică e-mail",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Ca parte a măsurilor noastre de securitate, rugăm utilizatorii să își verifice adresele de e-mail înainte de a putea continua cu configurarea conturilor lor pe 2value."
                    " \nCând creezi un cont, vom trimite automat un link de verificare. Te rugăm să verifici e-mailul pentru a verifica contul.",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Dacă ai verificat adresa de e-mail, poți da ",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        TextSpan(
                            text: 'refresh ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[400],
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                pr.show();
                                _reloadUser();
                              }),
                        TextSpan(
                          text:
                              'pe pagină pentru actualizare.\nDacă crezi că nu ai primit linkul de verificare, fă click aici pentru ',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        TextSpan(
                            text: 'a retrimite.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[400],
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                pr.show();
                                _sendVerificationEmail();
                              }),
                      ],
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
