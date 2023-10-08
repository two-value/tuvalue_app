import 'package:app/model/user.dart';
import 'package:app/model/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  //collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('Users');

  Future updateUserData(
    String userName,
    String userId,
    String userCountry,
    String userImage,
    String userAuthority,
    String userPower,
    String userPhone,
    String userPlan,
    String userVerification,
    String emailVerification,
    String accountType,
    String userEmail,
    String aboutUser,
  ) async {
    return await usersCollection.document(uid).setData(
      {
        'user_name': userName,
        'user_id': userId,
        'user_country': userCountry,
        'user_image': userImage,
        'user_authority': userAuthority,
        'user_power': userPower,
        'user_phone': userPhone,
        'user_plan': userPlan,
        'user_verification': userVerification,
        'email_verification': emailVerification,
        'account_type': accountType,
        'user_email': userEmail,
        'about_user': aboutUser,
      },
    );
  }

  //users list from a snapshot
  List<UserModel> _usersListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return UserModel(
        name: doc.data['user_name'] ?? '',
        country: doc.data['user_country'] ?? '',
        user_id: doc.data['user_id'] ?? '',
      );
    }).toList();
  }

  //user data from snapshot
  UserData _userDataFromSnapShot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data['user_name'],
      bio: snapshot.data['about_user'],
      url: snapshot.data['external_link'],
    );
  }

  //Get brews streams
  Stream<List<UserModel>> get users {
    return usersCollection.snapshots().map(_usersListFromSnapshot);
  }

  //get user doc stream
  Stream<UserData> get userData {
    return usersCollection.document(uid).snapshots().map(_userDataFromSnapShot);
  }
}
