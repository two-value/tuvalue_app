import 'dart:io';
import 'package:app/pages/HomePage.dart';
import 'package:app/services/auth.dart';
import 'package:app/shared/loading.dart';
import 'package:app/widgets/HeaderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SetupJournalistAccount extends StatefulWidget {
  @override
  _SetupJournalistAccountState createState() => _SetupJournalistAccountState();
}

class _SetupJournalistAccountState extends State<SetupJournalistAccount> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  bool _imageError = true;

  //text field state
  String email = '';
  String error = '';
  String name = '';
  String nick_name = '';
  String biography = '';
  String externalUrl = 'not set';
  String userPhone = 'not set';

  Map<String, bool> values = {
    'Economic': true,
    'Social': true,
    'Lifestyle': true,
    'Evenimente': true,
  };

  int _radioValue1 = -1;

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
//          Fluttertoast.showToast(
//              msg: 'Correct !', toastLength: Toast.LENGTH_SHORT);
//          correctScore++;
          break;
        case 1:
//          Fluttertoast.showToast(
//              msg: 'Try again !', toastLength: Toast.LENGTH_SHORT);
          break;
        case 2:
//          Fluttertoast.showToast(
//              msg: 'Try again !', toastLength: Toast.LENGTH_SHORT);
          break;
      }
    });
  }

//  bool complete = false;

  //image capture
  File _imageFile;
  String _uploadedFileURL;
  String onlineUserId;
  String onlineUserEmail;
  //end of image capture
  getImageFile(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 1000,
        maxWidth: 1000,
        compressQuality: 80,
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
      _imageError = false;
      print(_imageFile.lengthSync());
    });
  }

  //create data
  createData() {
    DocumentReference ds =
        Firestore.instance.collection('Users').document(onlineUserId);
    Map<String, dynamic> tasks = {
      'user_name': name,
      'account_type': 'Journalist',
      'email_verification': 'Verified',
      'user_authority': 'null',
      'user_email': onlineUserEmail,
      'user_id': onlineUserId,
      'user_image': _uploadedFileURL,
      'user_phone': userPhone,
      'user_city': 'Uncategorized',
      'user_plan': 'null',
      'press_left_count': 0,
      'event_left_count': 0,
      'interview_left_count': 0,
      'press_event_left_count': 0,
      'user_power': 'null',
      'registration_number': 'not set',
      'user_locality': 'Romania',
      'about_user': biography,
      'external_link': externalUrl,
      'user_verification': 'null',
      'subscriptions_count': 0,
      'presses_count': 0,
      'events_count': 0,
      'user_extra': 'extra',
      'notification_count': 0,
      'device_token': 'not set',
    };
    ds.setData(tasks).whenComplete(() {
      sendNotification();
    });
  }

  sendNotification() {
    DocumentReference ds = Firestore.instance
        .collection('Notifications')
        .document('important')
        .collection(onlineUserId)
        .document();
    Map<String, dynamic> tasks = {
      'notification_tittle': 'Bine ai venit pe 2value!',
      'notification_description':
          'Echipa 2value îți urează un călduros bun venit!',
      'notification_details':
          'Ne bucurăm că ești împreună cu noi. Ai reușit să creezi contul tău de jurnalist, iar informațiile furnizate au fost trimise către administrator pentru verificare. Dacă totul este în regulă, contul va fi aprobat în scurt timp.',
      'notification_time': DateTime.now().millisecondsSinceEpoch,
      'notification_sender': 'ckFE6BFaCceoeBbUDPJBiXBTvP52',
      'post_id': 'extra',
    };
    ds.setData(tasks).whenComplete(() {
      print('Tasks created');

      setState(() {
        //loading = false;
        //Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (Route<dynamic> route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black87,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _loading
          ? Container(
              color: Colors.white,
              child: SpinKitPulse(
                color: Theme.of(context).primaryColor,
                size: 100.0,
              ),
            )
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
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(
                              child: Container(
                                height: 160.0,
                                width: 160.0,
                                child: InkWell(
                                  child: _imageFile == null
                                      ? CircleAvatar(
                                          //backgroundColor: Colors.blue,
                                          //backgroundImage: FileImage(_imageFile),
                                          backgroundImage: AssetImage(
                                              'assets/images/profile_placeholder.jpg'),
                                          //foregroundColor: Colors.white,
                                          radius: 80,
                                          //child: Text('Select Image'),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          backgroundImage:
                                              FileImage(_imageFile),
                                          foregroundColor: Colors.white,
                                          radius: 80,
                                          //child: Text('Select Image'),
                                        ),
                                  onTap: () {
                                    getImageFile(ImageSource.gallery);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: _imageError,
                              child: Text(
                                'Alege foto',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Configurarea\nunui cont de jurnalist',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Numele',
                                helperText: 'Numele tău intră aici',
                                prefixIcon: Icon(
                                  Icons.person,
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
                                setState(() => name = val);
                              },
                              validator: (val) =>
                                  val.isEmpty ? 'Introdu un nume' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Pseudonimul tău',
                                helperText:
                                    'Pseudonimul tău va fi utilizat acolo unde confidențialitatea e importantă',
                                prefixIcon: Icon(
                                  Icons.person,
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
                                setState(() => nick_name = val);
                              },
                              validator: (val) =>
                                  val.isEmpty ? 'Introdu un pseudonim' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 300,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Biografia',
                                helperText: 'Biografia ta intră aici',
                                prefixIcon: Icon(
                                  Icons.description,
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
                                setState(() => biography = val);
                              },
                              validator: (val) => val.length < 100
                                  ? 'Biografia e prea scurtă, minim 100 caractere'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Telefon',
                                helperText: 'Numărul de telefon intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                prefixIcon: Icon(
                                  Icons.phone,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => userPhone = val);
                              },
                              validator: (val) => val.length < 10
                                  ? 'Introdu un număr de telefon valid'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'URL extern',
                                helperText:
                                    'Linkul tău extern intră aici (Facebook, LinkedIn, website)',
                                prefixIcon: Icon(
                                  Icons.link,
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
                                setState(
                                  () => externalUrl = val,
                                );
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Te rugăm să selectezi unde să te înscrii ca jurnalist. Oricând poți schimba setarea ulterior.',
                              style: TextStyle(fontSize: 18),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    new Radio(
                                      value: 0,
                                      groupValue: _radioValue1,
                                      onChanged: _handleRadioValueChange1,
                                    ),
                                    Expanded(
                                      child: new Text(
                                        'Înscrie-te pentru a primi actualizări',
                                        style: new TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    new Radio(
                                      value: 1,
                                      groupValue: _radioValue1,
                                      onChanged: _handleRadioValueChange1,
                                    ),
                                    Expanded(
                                      child: new Text(
                                        'Înscrie-te pentru a primi actualizări de știri în calitate de editor plătit',
                                        style: new TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Te rugăm să selectezi pe ce domeniu vrei să primești conținut.',
                              style: TextStyle(fontSize: 18),
                            ),
                            Container(
                              height: 240,
                              child: ListView(
                                children: values.keys.map((String key) {
                                  return new CheckboxListTile(
                                    title: new Text(key),
                                    value: values[key],
                                    onChanged: (bool value) {
                                      setState(() {
                                        values[key] = value;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(
                              height: 48,
                              child: FlatButton(
                                color: Colors.blue,
                                child: Text(
                                  'Trimite',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                                shape: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(8),
                                textColor: Colors.white,
                                onPressed: () async {
                                  if (_imageFile == null) {
                                  } else {
                                    if (_formKey.currentState.validate()) {
                                      setState(() => _loading = true);

                                      final FirebaseUser user =
                                          await FirebaseAuth.instance
                                              .currentUser();
                                      final uid = user.uid;
                                      final userEmail = user.email;
                                      // do something
                                      StorageReference storageReference =
                                          FirebaseStorage.instance
                                              .ref()
                                              .child('profiles/$uid');
                                      StorageUploadTask uploadTask =
                                          storageReference.putFile(_imageFile);
                                      await uploadTask.onComplete;
                                      print('File Uploaded');
                                      storageReference
                                          .getDownloadURL()
                                          .then((fileURL) {
                                        setState(() {
                                          _uploadedFileURL = fileURL;
                                          onlineUserId = uid;
                                          onlineUserEmail = userEmail;
                                          createData();
                                        });
                                      });
                                    } else {
                                      _autoValidate = true;
                                    }
                                  }
                                },
                              ),
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
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
