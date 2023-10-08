import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class PaymentService {
  addCard(token) {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('ProUsers')
          .document(user.uid)
          .collection('tokens')
          .add({'tokenId': token}).then((val) {
        print('saved');
      });
    });
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency}) async {}
}
