import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  getSubscriptionInfo(String subscriberUid, String subscribedUid) {
    return Firestore.instance
        .collection('Subscribers')
        .document('subscribed_users')
        .collection(subscribedUid)
        .where('subscriber_id', isEqualTo: subscriberUid)
        .getDocuments();
  }
}
