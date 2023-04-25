import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class ReportPost {
  String id_of_peron_who_reported_post;
  String post_id;
  String timestamp;
  String poster_id;

  /**
   * Creates blueprint for all posts, instating neccessary varaibles
   */

  ReportPost(
      {required this.id_of_peron_who_reported_post,
        required this.post_id,
        required this.timestamp,
        required this.poster_id,
      });


  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id_of_peron_who_reported_post: id_of_peron_who_reported_post,
      FirestoreConstants.post_id: post_id,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.poster_id: poster_id,
    };
  }

  factory ReportPost.fromDocument(DocumentSnapshot documentSnapshot) {
    String id_of_peron_who_reported_post = documentSnapshot.get(FirestoreConstants.id_of_peron_who_reported_post);
    String post_id = documentSnapshot.get(FirestoreConstants.post_id);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String poster_id = documentSnapshot.get(FirestoreConstants.poster_id);

    return ReportPost(
        id_of_peron_who_reported_post: id_of_peron_who_reported_post,
        post_id: post_id,
        timestamp: timestamp,
        poster_id: poster_id);
  }

}