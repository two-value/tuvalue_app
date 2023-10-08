import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ShareAppPage extends StatefulWidget {
  @override
  _ShareAppPageState createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Share 2value App"),
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(48.0),
                child: Icon(Icons.share, size: 32.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Help your friends know about 2value.\nA powerful platform to change how journalist and companies communicate. Press the button to choose where to share.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(48.0),
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 48.0,
                  child: FlatButton(
                    child: Text(
                      'Share App',
                      style: TextStyle(fontSize: 18),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.all(15),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Share.share(
                        'Download 2value. A mobile application that connects companies with journalists. Download here: http://play.google.com/store/apps/details?id=ro.twovalue.app',
                        subject: '2value',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
