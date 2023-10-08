import 'package:app/animations/FadeAnimations.dart';
import 'package:flutter/material.dart';

class EditPressEngagePage extends StatefulWidget {
  @override
  _EditPressEngagePageState createState() => _EditPressEngagePageState();
}

class _EditPressEngagePageState extends State<EditPressEngagePage> {
  TextEditingController _titleController;
  TextEditingController _summaryController;
  TextEditingController _bodyController;
  final key = new GlobalKey<ScaffoldState>();

  String newTitle = '';
  String newSummary = '';
  String newBody = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
                child: Text(
                  'Editing pane:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FlatButton(
                  child: Text(
                    'Update',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      //_updatePress();
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  FadeAnimation(
                    1,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _titleController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 100,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'The title',
                          helperText:
                              'The title of your press release goes here.',
                          contentPadding: const EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4.0),
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.brown),
                        ),
                        onChanged: (val) {
                          setState(() => newTitle = val);
                        },
                        validator: (val) =>
                            val.length < 5 ? 'Title too short' : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  FadeAnimation(
                    1,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _summaryController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 800,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Short summary',
                          helperText: 'Edit here to change the summary.',
                          contentPadding: const EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4.0),
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.brown),
                        ),
                        onChanged: (val) {
                          setState(() => newSummary = val);
                        },
                        validator: (val) =>
                            val.length < 5 ? 'Summary too short' : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  FadeAnimation(
                    1,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _bodyController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 10000,
                        autofocus: true,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'The body',
                          helperText: 'Edit here to change the main body.',
                          contentPadding: const EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4.0),
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.brown),
                        ),
                        onChanged: (val) {
                          setState(() => newBody = val);
                        },
                        validator: (val) =>
                            val.length < 5 ? 'Body too short' : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
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
    );
  }
}
