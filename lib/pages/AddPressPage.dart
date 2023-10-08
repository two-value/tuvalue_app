import 'dart:io';
import 'package:app/pages/PurchasePackage.dart';
import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;

class AddPress extends StatefulWidget {
  @override
  _AddPressState createState() => _AddPressState();
}

class _AddPressState extends State<AddPress> {
  final databaseReference = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String videoId = '';

  //categories dropdown
  final List<String> _pressCategories = [
    'Fără categorie',
    'Economic',
    'Social',
    'Lifestyle',
    'Event',
  ];

  //other
  File _imageFile;
  String _uploadedFileURL;
  String _externalPressUrl = 'null';
  String _onlineUserId;
  String _formattedDate;
  String pressAboutCompany = '';
  String author = '';
  bool checkedValue = false;

  //other
  String pressTitle = '';
  String pressSummary = '';
  String pressBody = '';
  String _selectedCategory = 'Fără categorie';
  String error = '';

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

  addPressCount() {
    DocumentReference usersRef =
        Firestore.instance.collection('Users').document(_onlineUserId);
    usersRef.updateData({'presses_count': FieldValue.increment(1)});
  }

  //create press
  _createPress() {
    DocumentReference ds = Firestore.instance.collection('Presses').document();
    Map<String, dynamic> _tasks = {
      'press_title': pressTitle,
      'press_body': pressBody,
      'press_image': _uploadedFileURL,
      'press_time_stamp': DateTime.now(),
      'press_time': DateTime.now().millisecondsSinceEpoch,
      'press_poster': _onlineUserId,
      'press_formatted_date': _formattedDate,
      'press_category': _selectedCategory,
      'press_summary': pressSummary,
      'press_external_url': _externalPressUrl,
      'press_read_count': 0,
      'press_ratings': 0,
      'press_status': 'null',
      'comments_count': 0,
      'share_count': 0,
      'about_company': pressAboutCompany,
      'press_event_agenda': 'press_agenda',
      'press_author': author,
      'press_video_id': videoId,
      'press_extra': checkedValue.toString(),
      'press_id': 'extra',
    };
    ds.setData(_tasks).whenComplete(() {
      DocumentReference documentReferences =
          Firestore.instance.collection('Presses').document(ds.documentID);
      Map<String, dynamic> _updateTasks = {
        'press_id': ds.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        createDataNode(ds.documentID);
        addPressCount();
        print('Press created');
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Trimis cu succes'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Postarea ta a fost trimisă cu succes'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Bine'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      });
    });
  }

  createDataNode(String documentID) {
    databaseReference
        .collection('Press_data')
        .document(_onlineUserId)
        .collection(documentID)
        .document('1_total_views')
        .setData({
      'total': 0,
      'color': '0xff8c9eff',
      'title': 'Views',
    });

    databaseReference
        .collection('Press_data')
        .document(_onlineUserId)
        .collection(documentID)
        .document('2_total_comments')
        .setData({
      'total': 0,
      'color': '0xff00796b',
      'title': 'Comments',
    });

    databaseReference
        .collection('Press_data')
        .document(_onlineUserId)
        .collection(documentID)
        .document('3_total_shares')
        .setData({
      'total': 0,
      'color': '0xff6d4c41',
      'title': 'Shares',
    });
  }
  //end of create press

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postează un comunicat de presă'),
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
                  color: Colors.white,
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
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Titlul',
                                helperText:
                                    'Titlul comunicatului de presă intră aici',
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
                                setState(() => pressTitle = val);
                              },
                              validator: (val) =>
                                  val.length < 5 ? 'Title too short' : null,
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
                                labelText: 'Categoria',
                                helperText:
                                    'Selectează categoria comunicatului de presă',
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
                                labelText: 'Introducerea',
                                helperText:
                                    'Lead-ul comunicatului de presă intră aici',
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
                                setState(() => pressSummary = val);
                              },
                              validator: (val) =>
                                  val.length < 50 ? 'Lead too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 10000,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Conținutul comunicatului de presă',
                                helperText:
                                    'Conținutul comunicatului intră aici',
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
                                setState(() => pressBody = val);
                              },
                              validator: (val) => val.length < 100
                                  ? 'Body too short, 100 chars min'
                                  : null,
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
                                  fontSize: 20.0,
                                  color: Colors.blue,
                                ),
                              ),
                              shape: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(15),
                              textColor: Colors.white,
                              onPressed: () async {
                                if (_imageFile == null) {
                                } else {
                                  if (_formKey.currentState.validate()) {
                                    setState(() => loading = true);
                                    _startUpload();
                                  } else {
                                    _autoValidate = true;
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  error,
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  _startUpload() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    // do something
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('presses/${Path.basename(_imageFile.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_imageFile);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _formattedDate = DateFormat.yMMMd().format(DateTime.now());
        _uploadedFileURL = fileURL;
        _onlineUserId = uid;
        _createPress();
      });
    });
  }
}
