import 'dart:io';

import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddPitchPage extends StatefulWidget {
  @override
  _AddPitchPageState createState() => _AddPitchPageState();
}

class _AddPitchPageState extends State<AddPitchPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String _error = '';
  DateTime _date = DateTime.now();

  final List<String> _pressCategories = [
    'Fără categorie',
    'Economic',
    'Social',
    'Lifestyle',
    'Evenimente',
  ];

  String _selectedCategory = 'Fără categorie';
  String _pitchTitle = '';
  String _author = '';
  String _subject = '';
  String _formattedDate;

  String pressAboutCompany = '';
  String author = '';
  bool checkedValue = false;

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

  _addPitch() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;
    print(uid);

    DocumentReference _pitchRef =
        Firestore.instance.collection('Pitches').document();
    Map<String, dynamic> _pitches = {
      'pitch_title': _pitchTitle,
      'pitch_body': _subject,
      'pitch_time_stamp': DateTime.now(),
      'pitch_time': DateTime.now().millisecondsSinceEpoch,
      'pitch_poster': uid,
      'pitch_formatted_date': _formattedDate,
      'pitch_category': _selectedCategory,
      'pitch_author': _author,
      'pitch_external_url': 'null',
      'pitch_read_count': 0,
      'pitch_ratings': 0,
      'pitch_status': 'Approved',
      'comments_count': DateTime.now().millisecondsSinceEpoch,
      'about_company': _author,
      'pitch_extra': 'extra',
      'pitch_id': 'extra',
    };
    await _pitchRef.setData(_pitches).whenComplete(() {
      DocumentReference documentReferences = Firestore.instance
          .collection('Pitches')
          .document(_pitchRef.documentID);
      Map<String, dynamic> _updateTasks = {
        'pitch_id': _pitchRef.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        print('Event created');
        setState(() {
          loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _formattedDate = DateFormat.yMMMd().format(_date);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Caută un subiect'),
        centerTitle: true,
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
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 120,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Lansează titlul subiectului',
                                helperText: 'Titlul subiectului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _pitchTitle = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Title too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField(
                              value: _selectedCategory ?? 'Fără categorie',
                              items: _pressCategories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedCategory = val());
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Categorie',
                                helperText: 'Alege categoria pentru subiect',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(4.0),
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 2800,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Conținutul subiectului',
                                helperText: 'Conținutul subiectului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _subject = val);
                              },
                              validator: (val) =>
                                  val.length < 10 ? 'Too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 800,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Autor',
                                helperText: 'Autorul intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _author = val);
                              },
                              validator: (val) => val.length < 50
                                  ? 'Too short, 50 chars min'
                                  : null,
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
                                helperText: 'Video ID intră aici',
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
                                  setState(
                                    () {
                                      loading = true;
                                      _addPitch();
                                    },
                                  );
                                } else {
                                  _autoValidate = true;
                                }
                              },
                            ),
                            SizedBox(
                              height: 40,
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
