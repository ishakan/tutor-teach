import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class WaitingModel extends Equatable {
  final String databaseid_stored;
  final String personid_waiting;
  final String name_waiting;
  final String timestamp_waiting;
  final String gradeLevel_waiting;
  final String fcmToken_waiting;

  const WaitingModel(
      {required this.databaseid_stored,
        required this.personid_waiting,
        required this.name_waiting,
        required this.timestamp_waiting,
        required this.gradeLevel_waiting,
        required this.fcmToken_waiting,
      });

  /**
   * Creates blueprint for any student user, instating neccessary varaibles
   */

  WaitingModel copyWith({
    String? databaseid_stored,
    String? personid_waiting,
    String? name_waiting,
    String? timestamp_waiting,
    String? gradeLevel_waiting,
    String? fcmToken_waiting,

  }) {
    return WaitingModel(
      databaseid_stored: databaseid_stored ?? this.databaseid_stored,
      personid_waiting: personid_waiting ?? this.personid_waiting,
      name_waiting: name_waiting ?? this.name_waiting,
      timestamp_waiting: timestamp_waiting ?? this.timestamp_waiting,
      gradeLevel_waiting: gradeLevel_waiting ?? this.gradeLevel_waiting,
      fcmToken_waiting: fcmToken_waiting ?? this.fcmToken_waiting,);
  }


  Map<String, dynamic> toJson() => {
    FirestoreConstants.databaseid_stored: databaseid_stored,
    FirestoreConstants.personid_waiting: personid_waiting,
    FirestoreConstants.name_waiting: name_waiting,
    FirestoreConstants.timestamp_waiting: timestamp_waiting,
    FirestoreConstants.gradeLevel_waiting: gradeLevel_waiting,
    FirestoreConstants.fcmToken_waiting: fcmToken_waiting,
  };
  factory WaitingModel.fromDocument(DocumentSnapshot snapshot) {
    String personidWaiting = "";
    String databaseidStored = "";
    String nameWaiting = "";
    String timestampWaiting = "";
    String gradeLevelWaiting = "";
    String fcmTokenWaiting = "";

    try {
      databaseidStored = snapshot.get(FirestoreConstants.databaseid_stored);
      personidWaiting = snapshot.get(FirestoreConstants.personid_waiting);
      nameWaiting = snapshot.get(FirestoreConstants.name_waiting);
      timestampWaiting = snapshot.get(FirestoreConstants.timestamp_waiting);
      gradeLevelWaiting = snapshot.get(FirestoreConstants.gradeLevel_waiting);
      fcmTokenWaiting = snapshot.get(FirestoreConstants.fcmToken_waiting);

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return WaitingModel(
        databaseid_stored: databaseidStored,
        name_waiting: nameWaiting,
        personid_waiting: personidWaiting, //String
        timestamp_waiting: timestampWaiting,
        gradeLevel_waiting: gradeLevelWaiting,
        fcmToken_waiting: fcmTokenWaiting,);
  }

  static WaitingModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return WaitingModel(
        databaseid_stored: snapshot["databaseid_stored"],
        name_waiting: snapshot["name_waiting"],
        personid_waiting: snapshot["personid_waiting"],
        timestamp_waiting: snapshot["timestamp_waiting"],
        gradeLevel_waiting: snapshot["gradeLevel_waiting"],
        fcmToken_waiting: snapshot["fcmToken_waiting"],);

  }

  // , historyState, mathState, artState, humanGeoState, civicsState, physicsState, elaState, languageState
  @override
  // TODO: implement props
  List<Object?> get props => [databaseid_stored, name_waiting, personid_waiting, timestamp_waiting, gradeLevel_waiting, fcmToken_waiting];
}
