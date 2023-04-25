import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class ReportUser {
  String id_of_peron_who_reported_user;
  String user_id;
  String timestamp;

  /**
   * Creates blueprint for all posts, instating neccessary varaibles
   */

  ReportUser(
      {required this.id_of_peron_who_reported_user,
        required this.user_id,
        required this.timestamp,
      });


  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id_of_peron_who_reported_post: id_of_peron_who_reported_user,
      FirestoreConstants.user_id: user_id,
      FirestoreConstants.timestamp: timestamp,
    };
  }

  factory ReportUser.fromDocument(DocumentSnapshot documentSnapshot) {
    String id_of_peron_who_reported_user = documentSnapshot.get(FirestoreConstants.id_of_peron_who_reported_user);
    String user_id = documentSnapshot.get(FirestoreConstants.user_id);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);

    return ReportUser(
        id_of_peron_who_reported_user: id_of_peron_who_reported_user,
        user_id: user_id,
        timestamp: timestamp);
  }

}