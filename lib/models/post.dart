import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class Post {
  String idFrom;
  String post_description;
  String timestamp;
  String post_title;
  String post_image;
  String displayName;
  List likes;
  List bookMarked;
  String photoUrl;
  int postId;

  /**
   * Creates blueprint for all posts, instating neccessary varaibles
   */

   Post(
      {required this.idFrom,
        required this.post_description,
        required this.timestamp,
        required this.post_title,
        required this.post_image,
        required this.displayName,
        required this.likes,
        required this.bookMarked,
        required this.photoUrl,
        required this.postId,
      });


  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.post_description: post_description,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.post_title: post_title,
      FirestoreConstants.post_image: post_image,
      FirestoreConstants.displayName: displayName,
      FirestoreConstants.likes: likes,
      FirestoreConstants.bookMarked: bookMarked,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.postId: postId,
    };
  }

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    String post_description = documentSnapshot.get(FirestoreConstants.post_description);
    String timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String post_title = documentSnapshot.get(FirestoreConstants.post_image);
    String post_image = documentSnapshot.get(FirestoreConstants.post_title);
    String displayName = documentSnapshot.get(FirestoreConstants.displayName);
    List likes = documentSnapshot.get(FirestoreConstants.likes);
    List bookMarked = documentSnapshot.get(FirestoreConstants.bookMarked);
    String photoUrl = documentSnapshot.get(FirestoreConstants.photoUrl);
    int postId = documentSnapshot.get(FirestoreConstants.postId);

    return Post(
        idFrom: idFrom,
        post_description: post_description,
        timestamp: timestamp,
        post_title: post_title,
        post_image: post_image,
        displayName: displayName,
        likes: likes,
        bookMarked: bookMarked,
        photoUrl: photoUrl,
        postId: postId);
  }

}