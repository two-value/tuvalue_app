import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class EventMethods {
  Future<void> addData(eventData) async {
    Firestore.instance.collection('testcrud').add(eventData).catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await Firestore.instance.collection('testcrud').getDocuments();
  }
}
