import 'dart:io';

import 'package:app/services/events/events.dart';
import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String pressAboutCompany = '';
  String author = '';
  bool checkedValue = false;
  EventMethods eventObj = new EventMethods();

  File _imageFile;
  String videoId = '';

  //get image file
  getImageFile(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 2),
        maxHeight: 1080,
        maxWidth: 1920,
        compressQuality: 70,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop your image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    setState(() {
      _imageFile = croppedFile;
      print(_imageFile.lengthSync());
    });
  }

  //date picker
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  Future<Null> _pickDate(BuildContext context) async {
    final DateTime _picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(Duration(minutes: 30)),
      lastDate: DateTime.now().add(Duration(days: 360)),
    );
    if (_picked != null) {
      setState(
        () {
          _date = _picked;
          _formattedDate = DateFormat.yMMMd().format(_date);
        },
      );
    }
  }

  Future<Null> _pickStartTime(BuildContext context) async {
    final TimeOfDay _picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (_picked != null) {
      setState(
        () {
          _time = _picked;
        },
      );
    }
  }

  Future<Null> _pickEndTime(BuildContext context) async {
    final TimeOfDay _picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (_picked != null) {
      setState(
        () {
          _endTime = _picked;
        },
      );
    }
  }

  //other
  String _eventTitle = '';
  String _eventDescription = '';
  String _eventLocation = '';
  String _error = '';
  String _formattedStartTimeOfDay;
  String _formattedEndTimeOfDay;
  String _formattedDate;

  //get image file

  //create press

  addEventCount(String uid) {
    DocumentReference usersRef =
        Firestore.instance.collection('Users').document(uid);
    usersRef.updateData({'events_count': FieldValue.increment(1)});
  }

  _createEvent() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;
    print(uid);

    DocumentReference _eventRef =
        Firestore.instance.collection('Events').document();
    Map<String, dynamic> _events = {
      'event_title': _eventTitle,
      'event_description': _eventDescription,
      'event_day': _formattedDate,
      'event_start_time': _formattedStartTimeOfDay,
      'event_end_time': _formattedEndTimeOfDay,
      'event_poster': uid,
      'event_venue': _eventLocation,
      'likes_count': 0,
      'comments_count': 0,
      'event_status': 'Approved',
      'event_extra': 'extra',
      'event_id': 'extra',
      'event_time_stamp': DateTime.now().millisecondsSinceEpoch,
      'interested_count': 0,
    };
    await _eventRef.setData(_events).whenComplete(() {
      DocumentReference documentReferences = Firestore.instance
          .collection('Events')
          .document(_eventRef.documentID);
      Map<String, dynamic> _updateTasks = {
        'event_id': _eventRef.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        addEventCount(uid);
        print('Event created');
        setState(() {
          Navigator.pop(context);
        });
      });
    });
  }
  //end of create press

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    setState(() {
      _formattedStartTimeOfDay = localizations.formatTimeOfDay(_time);
      _formattedEndTimeOfDay = localizations.formatTimeOfDay(_endTime);
      _formattedDate = DateFormat.yMMMd().format(_date);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Postează un eveniment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: loading
          ? Loading()
          : LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 120,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Titlu eveniment',
                                helperText: 'Titlul evenimentului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _eventTitle = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Title too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 200,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Descriere',
                                helperText:
                                    'Descrierea evenimentului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _eventDescription = val);
                              },
                              validator: (val) => val.length < 50
                                  ? 'description too short, 50 chars min'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('hello');
                              },
                              child: TextFormField(
                                //enabled: false,
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLength: 60,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Locație ',
                                  helperText:
                                      'Locul de desfășurare a evenimentului intră aici',
                                  contentPadding: const EdgeInsets.all(15.0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                  errorStyle: TextStyle(color: Colors.brown),
                                ),
                                onChanged: (val) {
                                  setState(() => _eventLocation = val);
                                },
                                validator: (val) =>
                                    val.length < 3 ? 'Title too short' : null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              shape: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () {
                                _pickDate(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.date_range,
                                                size: 18.0,
                                                color: Colors.teal,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "$_formattedDate",
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "  Schimbă",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Alege data evenimentului',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              shape: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () {
                                _pickStartTime(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.access_time,
                                                size: 18.0,
                                                color: Colors.teal,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  '$_formattedStartTimeOfDay',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "  Schimbă",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Alege ora de începere a evenimentului ',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              shape: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () {
                                _pickEndTime(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.access_time,
                                                size: 18.0,
                                                color: Colors.teal,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  "$_formattedEndTimeOfDay",
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "  Schimbă",
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Alege ora de încheiere a evenimentului',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 300,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Despre companie',
                                helperText: 'Despre companie intră aici',
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
                                setState(() => pressAboutCompany = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'About too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 300,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Autor',
                                helperText: 'Despre autor intră aici',
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
                                setState(() => author = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'About too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: AspectRatio(
                                aspectRatio: 1.5 / 1,
                                child: Container(
                                  //height: 160.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: InkWell(
                                    child: _imageFile == null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image(
                                              image: AssetImage(
                                                'assets/images/place_holder.png',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image(
                                              image: FileImage(_imageFile),
                                              fit: BoxFit.fill,
                                              //child: Text('Select Image'),
                                            ),
                                          ),
                                    onTap: () {
                                      getImageFile(ImageSource.gallery);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 300,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Youtube video',
                                helperText: 'Video Id goes here',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.teal,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(4.0),
                                  ),
                                ),
                                errorStyle: TextStyle(
                                  color: Colors.brown,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() => videoId = val);
                              },
                              validator: (val) => val.length < 6
                                  ? 'Video Id too short, 100 chars min'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            CheckboxListTile(
                              title: Text(
                                  "Permite jurnaliștilor să-ți editeze interviul"),
                              value: checkedValue,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValue = newValue;
                                });
                              },
                              activeColor: Colors.blue,
                              subtitle: Text(
                                  'Dacă bifezi această căsuță, permiți echipei noastre de jurnaliști să parcurgă conținutul postat și să facă modificările necesare, cu acordul tău.'),
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              child: Text(
                                'Trimite',
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.blue),
                              ),
                              shape: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(15),
                              textColor: Colors.white,
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                    _createEvent();
                                  });
                                } else {
                                  _autoValidate = true;
                                }
                              },
                            ),
                            SizedBox(
                              height: 30,
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
