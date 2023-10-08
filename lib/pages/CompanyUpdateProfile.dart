import 'dart:io';
import 'package:app/pages/ManagePayments.dart';
import 'package:app/services/profileData.dart';
import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompanyUpdateProfile extends StatefulWidget {
  @override
  _CompanyUpdateProfileState createState() => _CompanyUpdateProfileState();
}

class _CompanyUpdateProfileState extends State<CompanyUpdateProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _userFlag = false;
  var _details;

  @override
  void initState() {
    super.initState();

    getUser().then((user) async {
      if (user != null) {
        final FirebaseUser user = await _auth.currentUser();
        final uid = user.uid;

        ProfileService().getProfileInfo(uid).then((QuerySnapshot docs) {
          if (docs.documents.isNotEmpty) {
            setState(() {
              _userFlag = true;
              _details = docs.documents[0].data;
              onlineUserId = uid;
              nameInput = TextEditingController(text: _details['user_name']);
              bioInput = TextEditingController(text: _details['about_user']);
              urlInput = TextEditingController(text: _details['external_link']);
            });
          }
        });
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  TextEditingController nameInput;
  TextEditingController bioInput;
  TextEditingController urlInput;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameInput.dispose();
    bioInput.dispose();
    urlInput.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _imageError = true;
  String error = '';

  String name = '';
  String biography = '';
  String externalUrl = 'not set';

  //image capture
  File _imageFile;
  String _uploadedFileURL;
  String onlineUserId;
  //end of image capture
  getImageFile(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 512,
        maxWidth: 512,
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
  createDataWithNewImage() {
    DocumentReference ds =
        Firestore.instance.collection('Users').document(onlineUserId);
    Map<String, dynamic> tasks = {
      'user_name': name,
      'user_image': _uploadedFileURL,
      'about_user': biography,
      'external_link': externalUrl,
    };
    ds.updateData(tasks).whenComplete(() {
      print('Tasks created');
      setState(() {
        //loading = false;
        Navigator.pop(context, true);
      });
    });
  }

  createDataWithOldImage() {
    DocumentReference ds =
        Firestore.instance.collection('Users').document(onlineUserId);
    Map<String, dynamic> tasks = {
      'user_name': name,
      'about_user': biography,
      'external_link': externalUrl,
    };
    ds.updateData(tasks).whenComplete(() {
      print('Tasks created');
      setState(() {
        //loading = false;
        Navigator.pop(context, true);
      });
    });
  }

  Widget managePaymentsMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 30.0,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '0',
          child: Text('Payments & subscriptions'),
        ),
      ],
      onSelected: (retVal) {
        if (retVal == '0') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManagePayments(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizează profilul'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
//        actions: <Widget>[
//          managePaymentsMenuButton(),
//        ],
      ),
      body: _userFlag
          ? LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return Container(
                  color: Color.fromRGBO(246, 248, 253, 1),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight),
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
                                height: 50,
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
                                            backgroundImage: NetworkImage(
                                                _details['user_image']),
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
                              Text(
                                "Nume titular cont",
                                style: TextStyle(fontSize: 18.0),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: nameInput,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                maxLength: 30,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Personal / Company name',
                                  contentPadding: const EdgeInsets.all(15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  errorStyle: TextStyle(color: Colors.brown),
                                ),
                                validator: (val) =>
                                    val.isEmpty ? 'Enter a name' : null,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Biografie',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: bioInput,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                maxLength: 300,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Personal / Company bio',
                                  contentPadding: const EdgeInsets.all(15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  errorStyle: TextStyle(color: Colors.brown),
                                ),
                                validator: (val) => val.length < 100
                                    ? 'Biography too short, 100 chars min'
                                    : null,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Link extern',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: urlInput,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black54),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Brand url',
                                  contentPadding: const EdgeInsets.all(15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
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
                                height: 20,
                              ),
                              FlatButton(
                                child: Text(
                                  'Update',
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
                                  if (_imageFile == null) {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        _userFlag = false;
                                        name = nameInput.text;
                                        biography = bioInput.text;
                                        externalUrl = urlInput.text;
                                        createDataWithOldImage();
                                      });
                                      // do something
                                    } else {
                                      _autoValidate = true;
                                    }
                                  } else {
                                    if (_formKey.currentState.validate()) {
                                      setState(() => _userFlag = false);
                                      // do something
                                      StorageReference storageReference =
                                          FirebaseStorage.instance
                                              .ref()
                                              .child('profiles/$onlineUserId');
                                      StorageUploadTask uploadTask =
                                          storageReference.putFile(_imageFile);
                                      await uploadTask.onComplete;
                                      print('File Uploaded');
                                      storageReference
                                          .getDownloadURL()
                                          .then((fileURL) {
                                        setState(() {
                                          _userFlag = false;
                                          _uploadedFileURL = fileURL;
                                          name = nameInput.text;
                                          biography = bioInput.text;
                                          externalUrl = urlInput.text;
                                          createDataWithNewImage();
                                        });
                                      });
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : Loading(),
    );
  }
}
