import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FreePlanPage extends StatefulWidget {
  @override
  _FreePlanPageState createState() => _FreePlanPageState();
}

class _FreePlanPageState extends State<FreePlanPage> {
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
        appBar: AppBar(
          title: Text('Oops'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                'Free Plan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                ),
                child: Text(
                  'You are using a free account.\nPlease '
                  'upgrade to premeum account to be able to reach '
                  'more audience.\nClick the button below to purchase.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser('https://payment.2value.ro/');
                }),
                child: const Text('Purchase a subscription'),
              ),
            ],
          ),
        ));
  }
}
