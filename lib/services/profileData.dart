import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  getProfileInfo(String uid) {
    return Firestore.instance
        .collection('Users')
        .where('user_id', isEqualTo: uid)
        .getDocuments();
  }
}
