import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String url;
  final String email;
  final String bio;

  User({
    this.id,
    this.username,
    this.url,
    this.email,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc['user_email'],
      username: doc['user_name'],
      url: doc['user_image'],
      bio: doc['about_user'],
    );
  }
}
