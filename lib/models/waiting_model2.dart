import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class WaitingModel2 {
  final String databaseid_stored;
  final String personid_waiting;
  final String name_waiting;
  final String timestamp_waiting;
  final String gradeLevel_waiting;
  final String fcmToken_waiting;
  final String photoUrl_waiting;

  /**
   * Creates blueprint for all posts, instating neccessary varaibles
   */

  WaitingModel2(
      {required this.databaseid_stored,
        required this.personid_waiting,
        required this.name_waiting,
        required this.timestamp_waiting,
        required this.gradeLevel_waiting,
        required this.fcmToken_waiting,
        required this.photoUrl_waiting,
      });

  // ReportUser(
  //     {required this.id_of_peron_who_reported_user,
  //       required this.user_id,
  //       required this.timestamp,
  //     });

  Map<String, dynamic> toJson() => {
    FirestoreConstants.databaseid_stored: databaseid_stored,
    FirestoreConstants.personid_waiting: personid_waiting,
    FirestoreConstants.name_waiting: name_waiting,
    FirestoreConstants.timestamp_waiting: timestamp_waiting,
    FirestoreConstants.gradeLevel_waiting: gradeLevel_waiting,
    FirestoreConstants.fcmToken_waiting: fcmToken_waiting,
    FirestoreConstants.photoUrl_waiting: photoUrl_waiting,
  };

  // Map<String, dynamic> toJson() {
  //   return {
  //     FirestoreConstants.id_of_peron_who_reported_post: id_of_peron_who_reported_user,
  //     FirestoreConstants.user_id: user_id,
  //     FirestoreConstants.timestamp: timestamp,
  //   };
  // }

  factory WaitingModel2.fromDocument(DocumentSnapshot documentSnapshot) {
    String databaseid_stored = documentSnapshot.get(FirestoreConstants.databaseid_stored);
    String personid_waiting = documentSnapshot.get(FirestoreConstants.personid_waiting);
    String name_waiting = documentSnapshot.get(FirestoreConstants.name_waiting);
    String timestamp_waiting = documentSnapshot.get(FirestoreConstants.timestamp_waiting);
    String gradeLevel_waiting = documentSnapshot.get(FirestoreConstants.gradeLevel_waiting);
    String fcmToken_waiting = documentSnapshot.get(FirestoreConstants.fcmToken_waiting);
    String photoUrl_waiting = documentSnapshot.get(FirestoreConstants.photoUrl_waiting);

    return WaitingModel2(
        databaseid_stored: databaseid_stored,
        personid_waiting: personid_waiting,
        name_waiting: name_waiting,
        timestamp_waiting: timestamp_waiting,
        gradeLevel_waiting: gradeLevel_waiting,
        fcmToken_waiting: fcmToken_waiting,
        photoUrl_waiting: photoUrl_waiting,);
  }

}