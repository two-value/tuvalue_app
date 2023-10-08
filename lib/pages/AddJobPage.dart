import 'package:app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddJobPage extends StatefulWidget {
  @override
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  String _error = '';

  String _jobTitle = '';
  String _jobDescription = '';
  String _jobRequirements = '';
  String _jobContacts = '';

  _createJob() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final uid = _user.uid;

    DocumentReference _JobRef =
        Firestore.instance.collection('New_jobs').document();
    Map<String, dynamic> _jobs = {
      'posted_job_title': _jobTitle,
      'posted_job_description': _jobDescription,
      'posted_job_requirements': _jobRequirements,
      'posted_job_time_stamp': DateTime.now(),
      'posted_job_time': DateTime.now().millisecondsSinceEpoch,
      'posted_job_poster': uid,
      'posted_job_formatted_date': DateTime.now(),
      'posted_job_contacts': _jobContacts,
      'posted_job_category': uid,
      'posted_job_extra': 'Approved',
      'posted_job_id': 'extra',
    };
    await _JobRef.setData(_jobs).whenComplete(() {
      DocumentReference documentReferences = Firestore.instance
          .collection('New_jobs')
          .document(_JobRef.documentID);
      Map<String, dynamic> _updateTasks = {
        'posted_job_id': _JobRef.documentID,
      };
      documentReferences.updateData(_updateTasks).whenComplete(() {
        print('Job created');
        setState(() {
          Navigator.pop(context);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postează un job'),
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
                                labelText: 'Numele job-ului',
                                helperText: 'Job title goes here.',
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
                              maxLength: 500,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Descrierea job-ului',
                                helperText: 'Descrierea job-ului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _jobDescription = val);
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
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 200,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Cerințele job-ului',
                                helperText: 'Cerințele job-ului intră aici',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _jobRequirements = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              //enabled: false,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              maxLength: 200,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black54),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Contacte',
                                helperText: 'Cum te pot contacta solicitanții',
                                contentPadding: const EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                errorStyle: TextStyle(color: Colors.brown),
                              ),
                              onChanged: (val) {
                                setState(() => _jobContacts = val);
                              },
                              validator: (val) =>
                                  val.length < 3 ? 'Answer too short' : null,
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
                                    _createJob();
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
