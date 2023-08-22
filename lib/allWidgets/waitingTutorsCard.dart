import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/book_mark_animation.dart';
import 'package:google_firebase_signin/models/chat_user.dart' as model;
import 'package:google_firebase_signin/providers/chat_provider.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_firebase_signin/providers/user_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/screens/chat_page.dart';
import 'package:google_firebase_signin/screens/profile_page.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/utilities/keyboard_utils.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:google_firebase_signin/allWidgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class waitingTutorsCard extends StatefulWidget {
  final snap;
  final isAdmin;
  final schoolName;
  const waitingTutorsCard({
    Key? key,
    required this.snap,
    required this.isAdmin,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<waitingTutorsCard> createState() => _waitingTutorsCardState();
}

/**
 * structure for all student users
 */


class _waitingTutorsCardState extends State<waitingTutorsCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLikeAnimating = false;
  static const webScreenSize = 600;
  // late final FirebaseFirestore firebaseFirestore;

  // late String currentUserId;
  // String idTo = "";
  // String peerName = "";
  // static String displayBlockString = "";
  // String photoUrl = "";
  // String previousMessage = "";
  // String timestamp = "";
  double width = 0.0;
  // String uid = "";
  // String state_of_block = "";
  late ProfileProvider profileProvider;
  // late bool isBlocked;
  bool isChecked = false; // Track the checked state

  String dialCodeDigits = '+00';
  String databaseid_stored = "";
  String personid_waiting = "";
  String name_waiting = "";
  String timestamp_waiting = "";
  String gradeLevel_waiting = "";
  String fcmToken_waiting = "";
  String photoUrl_waiting = "";

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
    print("THIS SET VALUE VALUE2");
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }



  void readLocal() {
    setState(() {
      databaseid_stored = widget.snap['databaseid_stored'].toString();
      personid_waiting = widget.snap['personid_waiting'].toString();
      name_waiting = widget.snap['name_waiting'];
      timestamp_waiting = widget.snap['timestamp_waiting'].toString();
      gradeLevel_waiting = widget.snap['gradeLevel_waiting'].toString();
      fcmToken_waiting = widget.snap['fcmToken_waiting'].toString();
      photoUrl_waiting = widget.snap['photoUrl_waiting'].toString();
    });
  }


  FullydeletePost() async {
    try {
      await deletePost();
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  Future<String> deletePost() async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(widget.schoolName);
    String res = "Some error occurred";

    try {
      await _SchooldocRef.collection('waiting').doc(databaseid_stored).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }



  void updateForApproval() {
    String approved = "yes";

    _firestore
        .collection('schools').doc(widget.schoolName)
        .collection(FirestoreConstants.pathUserCollection)
        .doc(personid_waiting)
        .update({
      FirestoreConstants.approved: approved,
    });

  }

  @override
  Widget build(BuildContext context)  {
    final firebaseAuth = FirebaseAuth.instance;

    if (personid_waiting != "null") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        // padding: const EdgeInsets.all(8.0), // Add padding from all sides
        child: Container(
          // color: AppColors.greyColor,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:Color(0xffE4E4E4)
            // border: Border.all(color: Colors.black),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add inner padding for the entire content
            child: ListTile(
              contentPadding: EdgeInsets.zero, // Remove the default ListTile padding

              leading: Padding(
                padding: const EdgeInsets.all(4.0), // Add inner padding for the photo
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(color: Colors.black),
                  ),
                  child: photoUrl_waiting.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.dimen_30),
                    child: Image.network(
                      photoUrl_waiting,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
                ),
              ),

              title: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0), // Add inner horizontal padding for the name
                      child: Text(
                        "$name_waiting - $gradeLevel_waiting",
                        style: TextStyle(color: Colors.black, fontFamily: 'Gilroy'),
                        softWrap: false,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 24), // Add SizedBox to create space between name and checkmark
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0), // Add inner padding for the checkmark
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          print(isChecked);
                          // if (is)
                          if (!isChecked) {
                            print(" IS IT TOGGLING?");
                            updateForApproval();
                            FullydeletePost();
                            isChecked = !isChecked; // Toggle the checked state
                          }
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   color: isChecked ? Colors.green : Colors.transparent, // Use green color when checked, transparent when unchecked
                        // ),
                        child: Icon(
                          (!isChecked) ? Icons.check_circle_outline : Icons.check_circle,
                          color: Colors.green, // Use white color for the checkmark icon when checked, green when unchecked
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }


}