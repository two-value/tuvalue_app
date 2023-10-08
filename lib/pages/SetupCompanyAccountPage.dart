import 'dart:io';
import 'package:app/pages/HomePage.dart';
import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SetupCompanyAccount extends StatefulWidget {
  @override
  _SetupCompanyAccountState createState() => _SetupCompanyAccountState();
}

class _SetupCompanyAccountState extends State<SetupCompanyAccount> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  bool _imageError = true;
  String _selectedCity = 'Alege orașul';

  //categories dropdown
  final List<String> categories = [
    'Alege orașul',
    'Alba',
    'Arad',
    'Argeș',
    'Bacău',
    'Bihor',
    'Bistrița-Năsăud',
    'Botoșani',
    'Brașov',
    'Brăila',
    'București',
    'Buzău',
    'Caraș-Severin',
    'Călărași',
    'Cluj',
    'Constanța',
    'Covasna',
    'Dâmbovița',
    'Dolj',
    'Galați',
    'Giurgiu',
    'Gorj',
    'Harghita',
    'Hunedoara',
    'Ialomița',
    'Iași',
    'Ilfov',
    'Maramureș',
    'Mehedinți',
    'Mureș',
    'Neamț',
    'Olt',
    'Prahova',
    'Satu Mare',
    'Sălaj',
    'Sibiu',
    'Suceava',
    'Teleorman',
    'Timiș',
    'Tulcea',
    'Vaslui',
    'Vâlcea',
    'Vrancea',
  ];

  // radio button
  //text field state
  String email = '';
  String error = '';
  String name = '';
  String registrationNumber = '';
  String biography = '';
  String externalUrl = 'not set';
  String userPhone = 'not set';

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
    });
  }

  //create data
  createData() {
    DocumentReference ds =
        Firestore.instance.collection('Users').document(onlineUserId);
    Map<String, dynamic> tasks = {
      'user_name': name,
      'account_type': 'Company',
      'email_verification': 'Verified',
      'user_authority': 'null',
      'user_email': onlineUserEmail,
      'user_id': onlineUserId,
      'user_image': _uploadedFileURL,
      'user_phone': userPhone,
      'user_city': _selectedCity,
      'user_plan': 'null',
      'press_left_count': 0,
      'event_left_count': 0,
      'interview_left_count': 0,
      'press_event_left_count': 0,
      'user_power': 'null',
      'registration_number': registrationNumber,
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
    ds.setData(tasks).whenComplete(
      () {
        sendNotification();
      },
    );
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
          'Ne bucurăm că ești împreună cu noi. Ai reușit să creezi contul companiei, iar informațiile furnizate au fost trimise către administrator pentru verificare. '
              'Dacă totul este în regulă, contul va fi aprobat în scurt timp.',
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
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black87,
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
                            SizedBox(
                              height: 0,
                            ),
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
                                'Selectează logo',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Configurează\nun cont de companie',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 50,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Numele companiei',
                                helperText: 'Numele companiei intră aici',
                                prefixIcon: Icon(
                                  Icons.business,
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
                              validator: (val) => val.isEmpty
                                  ? 'Introdu numele companiei'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField(
                              value: _selectedCity ?? 'Alege orașul',
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedCity = val);
                              },

                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Oraș',
                                helperText: 'Numele orașului intră aici ',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),

//                              decoration: InputDecoration(
//                                filled: true,
//                                fillColor: Colors.white,
//                                contentPadding: const EdgeInsets.symmetric(
//                                    horizontal: 15.0, vertical: 2.0),
//                                focusedBorder: OutlineInputBorder(
//                                  borderSide: BorderSide(color: Colors.white),
//                                  borderRadius: BorderRadius.circular(5),
//                                ),
//                                enabledBorder: UnderlineInputBorder(
//                                  borderSide: BorderSide(color: Colors.white),
//                                  borderRadius: BorderRadius.circular(5),
//                                ),
//                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'Numărul de înregistrare al companiei',
                                helperText:
                                    'Numărul de înregistrare intră aici',
                                prefixIcon: Icon(
                                  Icons.confirmation_number,
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
                                setState(() => registrationNumber = val);
                              },
                              validator: (val) => val.isEmpty
                                  ? 'Introdu numărul de înregistrare'
                                  : null,
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
                                labelText: 'Descrierea companiei',
                                helperText: 'Descrierea companiei intră aici',
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
                                  ? 'Biografie prea scurtă, minim 100 caractere'
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
                                helperText: 'Telefonul intră aici',
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
                                  ? 'Enter a valid phone number'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Website companie',
                                helperText: 'Website companie intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                prefixIcon: Icon(
                                  Icons.link,
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
                                setState(() => externalUrl = val);
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 48.0,
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
                                padding: const EdgeInsets.all(10),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() => _loading = true);

                                    // do something

                                    final FirebaseUser user = await FirebaseAuth
                                        .instance
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
