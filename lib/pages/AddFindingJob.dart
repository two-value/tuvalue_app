import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddFindingJob extends StatefulWidget {
  @override
  _AddFindingJobState createState() => _AddFindingJobState();
}

class _AddFindingJobState extends State<AddFindingJob> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String _error = '';
  DateTime _date = DateTime.now();

  String _jobTitle = '';
  String _aboutYou = '';
  String _yourSkills = '';
  String _pdfLink = '';
  String _formattedDate;

  _findJob() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;

    DocumentReference _JobRef =
        Firestore.instance.collection('Find_jobs').document();
    Map<String, dynamic> _jobs = {
      'find_job_title': _jobTitle,
      'find_job_about': _aboutYou,
      'find_job_skills': _yourSkills,
      'find_job_cv': _pdfLink,
      'find_job_time_stamp': DateTime.now(),
      'find_job_time': DateTime.now().millisecondsSinceEpoch,
      'find_job_poster': uid,
      'find_job_formatted_date': _formattedDate,
      'find_job_extra': 'Approved',
      'find_job_id': 'extra',
    };
    await _JobRef.setData(_jobs).whenComplete(() {
      DocumentReference documentReferences = Firestore.instance
          .collection('Find_jobs')
          .document(_JobRef.documentID);
      Map<String, dynamic> _updateTasks = {
        'find_job_id': _JobRef.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        print('Job finding created');
        setState(() {
          loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Găsește un job '),
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
                              maxLength: 60,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Denumirea job-ului',
                                helperText: 'Denumirea job-ului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _jobTitle = val);
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
                                labelText: 'Despre tine',
                                helperText:
                                    'O scurtă biografie a ta intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _aboutYou = val);
                              },
                              validator: (val) => val.length < 50
                                  ? 'Too short, 50 chars min'
                                  : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 300,
                              maxLines: null,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Aptitudinile tale',
                                helperText: 'Aptitudinile tale intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _yourSkills = val);
                              },
                              validator: (val) =>
                                  val.length < 10 ? 'Too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 300,
                              maxLines: null,

                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.attach_file),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Atașează CV',
                                helperText: 'CV-ul tău intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _pdfLink = val);
                              },
                              validator: (val) =>
                                  val.length == 0 ? 'Atașează CV' : null,
                            ),
                            SizedBox(
                              height: 30,
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
                                    _findJob();
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
