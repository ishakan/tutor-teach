import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';


class BadMessages {
  String idFrom;
  String idTo;
  String nameFrom;
  String nameTo;
  String senderPhoto;
  String receiverPhoto;
  int timestamp;
  String content;
  int type;

  /**
   * Creates blueprint to bad messages, instating neccessary varaibles
   */

  BadMessages(
      {required this.idFrom,
        required this.idTo,
        required this.timestamp,
        required this.nameFrom,
        required this.nameTo,
        required this.senderPhoto,
        required this.receiverPhoto,
        required this.content,
        required this.type});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.nameFrom : nameFrom,
      FirestoreConstants.nameTo : nameTo,
      FirestoreConstants.senderPhoto : senderPhoto,
      FirestoreConstants.receiverPhoto : receiverPhoto,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
    };
  }

  factory BadMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(FirestoreConstants.idFrom);
    String idTo = documentSnapshot.get(FirestoreConstants.idTo);
    int timestamp = documentSnapshot.get(FirestoreConstants.timestamp);
    String nameFrom = documentSnapshot.get(FirestoreConstants.nameFrom);
    String nameTo = documentSnapshot.get(FirestoreConstants.nameTo);
    String senderPhoto = documentSnapshot.get(FirestoreConstants.senderPhoto);
    String receiverPhoto = documentSnapshot.get(FirestoreConstants.receiverPhoto);
    String content = documentSnapshot.get(FirestoreConstants.content);
    int type = documentSnapshot.get(FirestoreConstants.type);

    return BadMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        nameFrom: nameFrom,
        nameTo: nameTo,
        senderPhoto: senderPhoto,
        receiverPhoto: receiverPhoto,
        content: content,
        type: type);
  }
}
