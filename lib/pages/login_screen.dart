import 'package:app/animations/FadeAnimations.dart';
import 'package:app/pages/reset_password_screen.dart';
import 'package:app/pages/wrapper.dart';
import 'package:app/services/auth.dart';
import 'package:app/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  double _errorBox = 0;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      //return user;

      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Wrapper(),
            ),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      setState(
        () {
          loading = false;
          error = e.message;
          _errorBox = 1;
        },
      );
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
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.enhanced_encryption),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPassword(),
                      ),
                    );
                  },
                )
              ],
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
                          minHeight: viewportConstraints.maxHeight),
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
                                'Autentificare',
                                style: TextStyle(
                                  fontSize: 34.0,
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
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
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
                                  errorStyle: TextStyle(color: Colors.white),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _errorBox = 0;
                                    email = val.trim();
                                  });
                                },
                                validator: (val) =>
                                    !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                            .hasMatch(val)
                                        ? 'Introdu o adresă de e-mail validă'
                                        : null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FadeAnimation(
                              1.3,
                              TextFormField(
                                keyboardType: TextInputType.text,
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
                                onChanged: (val) {
                                  setState(() {
                                    _errorBox = 0;
                                    password = val.trim();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
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
                                      signInWithEmailAndPassword(
                                          email, password);
                                    } else {
                                      _autoValidate = true;
                                    }
                                  },
                                  child: Text(
                                    "Autentificare",
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
                              ),
                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.error,
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          error,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
