import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';


class MessageModel {
  String user_one;
  String user_two;

  /**
   * Creates blueprint to bad messages, instating neccessary varaibles
   */

  MessageModel(
      {required this.user_one,
        required this.user_two});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.user_one: user_one,
      FirestoreConstants.user_two: user_two,
    };
  }

  factory MessageModel.fromDocument(DocumentSnapshot documentSnapshot) {
    String user_one = documentSnapshot.get(FirestoreConstants.user_one);
    String user_two = documentSnapshot.get(FirestoreConstants.user_two);

    return MessageModel(
        user_one: user_one,
        user_two: user_two);
  }
}
