import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class ChatUser extends Equatable {
  final String id;

  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;
  final String testing;
  final String isTutor;
  final String email;
  final String schoolName;
  final String fcmToken;

  const ChatUser(
      {required this.id,
      required this.photoUrl,
      required this.displayName,
      required this.phoneNumber,
      required this.aboutMe,
      required this.testing,
      required this.isTutor,
      required this.email,
      required this.schoolName,
      required this.fcmToken,
      });

  /**
   * Creates blueprint for any student user, instating neccessary varaibles
   */

  ChatUser copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? testing,
    String? phoneNumber,
    String? email,
    String? tutor,
    String? email_address,
    String? school_name,
    String? fcmToken,

  }) {
    return ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          aboutMe: email ?? aboutMe,
          testing: testing ?? this.testing,
          isTutor: tutor ?? isTutor,
          email: email_address ?? this.email,
          schoolName: school_name ?? this.schoolName,
          fcmToken: fcmToken ?? this.fcmToken);
  }


  Map<String, dynamic> toJson() => {
        FirestoreConstants.displayName: displayName,
        FirestoreConstants.photoUrl: photoUrl,
        FirestoreConstants.phoneNumber: phoneNumber,
        FirestoreConstants.aboutMe: aboutMe,
        FirestoreConstants.testing: testing,
        FirestoreConstants.isTutor: isTutor,
        FirestoreConstants.email: email,
        FirestoreConstants.schoolName: schoolName,
        FirestoreConstants.fcmToken: fcmToken,
  };
  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String aboutMe = "";
    String testing = "";
    String isTutor = "";
    String email = "";
    String schoolName = "";
    String fcmToken = "";

    try {
      photoUrl = snapshot.get(FirestoreConstants.photoUrl);
      nickname = snapshot.get(FirestoreConstants.displayName);
      phoneNumber = snapshot.get(FirestoreConstants.phoneNumber);
      aboutMe = snapshot.get(FirestoreConstants.aboutMe);
      testing = snapshot.get(FirestoreConstants.testing);
      isTutor = snapshot.get(FirestoreConstants.isTutor);
      email = snapshot.get(FirestoreConstants.email);
      schoolName = snapshot.get(FirestoreConstants.schoolName);
      fcmToken = snapshot.get(FirestoreConstants.fcmToken);

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.data().toString().contains('id') ? snapshot.get('id') : '', //String
        // photoUrl: snapshot.data()['id'],

        // id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe,
        testing: testing,
        isTutor: isTutor,
        email: email,
        schoolName: schoolName,
        fcmToken: fcmToken);
  }

  static ChatUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return ChatUser(
      id: snapshot["id"],
      photoUrl: snapshot["photoUrl"],
      displayName: snapshot["displayName"],
      phoneNumber: snapshot["phoneNumber"],
      aboutMe: snapshot["aboutMe"],
      testing: snapshot["testing"],
      isTutor: snapshot["isTutor"],
      email: snapshot["email"],
      schoolName: snapshot["schoolName"],
      fcmToken: snapshot["fcmToken"]);

  }

  // , historyState, mathState, artState, humanGeoState, civicsState, physicsState, elaState, languageState
  @override
  // TODO: implement props
  List<Object?> get props => [id, photoUrl, displayName, phoneNumber, aboutMe, testing, isTutor, email, schoolName, fcmToken];
}
