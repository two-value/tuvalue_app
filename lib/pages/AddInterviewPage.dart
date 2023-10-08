import 'dart:io';

import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;

class AddInterviewPage extends StatefulWidget {
  @override
  _AddInterviewPageState createState() => _AddInterviewPageState();
}

class _AddInterviewPageState extends State<AddInterviewPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String _error = '';
  String _interviewTitle = '';
  String _interviewIdea = '';
  String _interviewDevelopment = '';
  String _interviewFinance = '';
  String _interviewTurnover = '';
  String _interviewPlans = '';
  String _interviewChallenges = '';
  String pressAboutCompany = '';
  String author = '';
  bool checkedValue = false;

  File _imageFile;
  String videoId = '';

  String _uploadedFileURL;
  String _onlineUserId;
  String _formattedDate;

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

  _createInterview() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;
    print(uid);

    DocumentReference _interviewsRef =
        Firestore.instance.collection('Interviews').document();
    Map<String, dynamic> _events = {
      'interview_title': _interviewTitle,
      'interview_image': _uploadedFileURL,
      'interview_idea': _interviewIdea,
      'interview_development': _interviewDevelopment,
      'interview_finance': _interviewFinance,
      'interview_turnover': _interviewTurnover,
      'interview_challenges': _interviewChallenges,
      'interview_plans': _interviewPlans,
      'interview_time_stamp': DateTime.now(),
      'interview_time': DateTime.now().millisecondsSinceEpoch,
      'interview_poster': uid,
      'interview_formatted_date': 'Approved',
      'interview_extra': 'extra',
      'interview_id': 'extra',
    };
    await _interviewsRef.setData(_events).whenComplete(() {
      DocumentReference documentReferences = Firestore.instance
          .collection('Interviews')
          .document(_interviewsRef.documentID);
      Map<String, dynamic> _updateTasks = {
        'interview_id': _interviewsRef.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        print('Interview created');
        setState(() {
          Navigator.pop(context);
        });
      });
    });
  }
  //end of create press

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postează un interviu'),
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
                              maxLength: 100,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Titlu interviu',
                                helperText: 'Titlul interviului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewTitle = val);
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
                              maxLength: 800,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Cum ți-a venit ideea de afacere?',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewIdea = val);
                              },
                              validator: (val) => val.length < 50
                                  ? 'Answer too short, 50 chars min'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 800,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'Cum ai dezvoltat afacerea/proiectul? ',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewDevelopment = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 1200,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'Cum ai finanțat afacerea/proiectul?',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewFinance = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 1200,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Ce cifră de afaceri ai atins?',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewTurnover = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 1200,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Care sunt principalele provocări? ',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewChallenges = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 1300,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'Care sunt previziunile de business?',
                                helperText:
                                    '3-5 propoziții care răspund la întrebare',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _interviewPlans = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 1200,
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
                                helperText: 'Autorul intră aici',
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
                                  setState(() {
                                    loading = true;
                                    _startUpload();
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

  _startUpload() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    // do something
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('Interviews/${Path.basename(_imageFile.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_imageFile);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _formattedDate = DateFormat.yMMMd().format(DateTime.now());
        _uploadedFileURL = fileURL;
        _onlineUserId = uid;
        _createInterview();
      });
    });
  }
}
