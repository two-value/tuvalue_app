import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  getDashInfo(String string) {
    return Firestore.instance
        .collection('Dashboard_data')
        .where('title', isEqualTo: string)
        .getDocuments();
  }
}
