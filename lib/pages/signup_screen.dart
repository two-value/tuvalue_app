import 'package:app/animations/FadeAnimations.dart';
import 'package:app/pages/wrapper.dart';
import 'package:app/services/auth.dart';
import 'package:app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double _errorBox = 0;
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String _secondPassword = '';
  String error = '';

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      //return user;
      if (user != null) {
        await user.sendEmailVerification();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Wrapper(),
            ),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      setState(() {
        error = e.message;
        _errorBox = 1;
      });

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              //title: Text('Login'),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: Theme.of(context).primaryColor,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidate: _autoValidate,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            FadeAnimation(
                              1.0,
                              Text(
                                ' Înregistrează-te',
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FadeAnimation(
                              1.3,
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) =>
                                    !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                            .hasMatch(val)
                                        ? 'Introdu o adresă de e-mail validă'
                                        : null,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black54,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'E-mail',
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  contentPadding: const EdgeInsets.all(15.0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                  ),
                                  errorStyle: TextStyle(color: Colors.brown),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _errorBox = 0;
                                    email = val;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FadeAnimation(
                              1.3,
                              TextFormField(
                                keyboardType: TextInputType.text,
                                onChanged: (val) {
                                  setState(() {
                                    _errorBox = 0;
                                    password = val;
                                  });
                                },
                                validator: (val) => val.length < 6
                                    ? 'Parolă prea scurtă'
                                    : null,
                                obscureText: true,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Parola',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                  ),
                                  contentPadding: const EdgeInsets.all(15.0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                  ),
                                  errorStyle: TextStyle(color: Colors.brown),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FadeAnimation(
                              1.3,
                              TextFormField(
                                keyboardType: TextInputType.text,
                                validator: (val) => val != password
                                    ? 'Parola nu se potrivește'
                                    : null,
                                obscureText: true,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Confirmă parola',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                    ),
                                    contentPadding: const EdgeInsets.all(15.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.teal),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(color: Colors.brown)),
                                onChanged: (val) {
                                  setState(
                                    () {
                                      _errorBox = 0;
                                      _secondPassword = val;
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            FadeAnimation(
                                1.6,
                                ButtonTheme(
                                  minWidth: 200.0,
                                  height: 48.0,
                                  child: RaisedButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        setState(() => loading = true);
                                        registerWithEmailAndPassword(
                                            email, password);
                                      } else {
                                        _autoValidate = true;
                                      }
                                    },
                                    child: Text(
                                      "Conectează-te",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(24.0),
                                    ),
                                  ),
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            AnimatedOpacity(
                              opacity: _errorBox,
                              duration: Duration(seconds: 1),
                              child: Container(
                                color: Colors.amberAccent,
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.error_outline),
                                    Flexible(
                                      child: Text(
                                        error,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
