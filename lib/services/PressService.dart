import 'package:cloud_firestore/cloud_firestore.dart';

class PressDetailsService {
  getPressInfo(String postId) {
    return Firestore.instance
        .collection('Presses')
        .where('press_id', isEqualTo: postId)
        .getDocuments();
  }
}
