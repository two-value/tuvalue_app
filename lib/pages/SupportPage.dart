import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Future<void> _launched;

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
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
          title: Text('Sprijin pentru clienți'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image(
                  image: AssetImage('assets/images/contact.png'),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Contactează echipa:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  'Echipa noastră lucrează în prezent la asistența live pe chat. Dacă sunt probleme, nu ezita să ne contactezi prin intermediul coordonatelor de mai jos.'),
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text(
                  'E-mail',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('office@tudor-communication.ro'),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text(
                  'Messenger',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('m.me/2Value-109123317193036'),
                onTap: () {
                  setState(() {
                    _launched = _launchInBrowser(
                        'https://www.facebook.com/2Value-109123317193036/');
                  });
                },
              ),
            ],
          ),
        ));
  }
}
