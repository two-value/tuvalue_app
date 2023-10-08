import 'package:app/pages/AddEventPage.dart';
import 'package:app/pages/AddPressPage.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatefulWidget {
  @override
  _PostScreenPageState createState() => _PostScreenPageState();
}

class _PostScreenPageState extends State<PostScreenPage> {
  bool _pressPage = true;
  String _appBarTitle = 'Post press release:';
  String _buttonTitle = 'Post your event';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_pressPage == true) {
                    _pressPage = false;
                    _appBarTitle = 'Post your event:';
                    _buttonTitle = 'Post press release';
                  } else {
                    _pressPage = true;
                    _appBarTitle = 'Post press release:';
                    _buttonTitle = 'Post your event';
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  //color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    color: Colors.transparent,
                    borderRadius: new BorderRadius.circular(5.0),
                  ),

                  child: Text(
                    _buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pressPage == true ? AddPress() : AddEvent(),
    );
  }
}
