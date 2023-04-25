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

class UserCard extends StatefulWidget {
  final snap;
  final isAdmin;
  final schoolName;
  const UserCard({
    Key? key,
    required this.snap,
    required this.isAdmin,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

/**
 * structure for all student users
 */


class _UserCardState extends State<UserCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLikeAnimating = false;
  static const webScreenSize = 600;
  late String currentUserId;
  String idTo = "";
  String peerName = "";
  static String displayBlockString = "";
  String photoUrl = "";
  String previousMessage = "";
  String timestamp = "";
  double width = 0.0;
  String uid = "";
  String state_of_block = "";
  late ProfileProvider profileProvider;
  late bool isBlocked;

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

  void readLocal()  {
    setState(() {
      idTo = widget.snap['idTo'].toString();
      peerName = widget.snap['peerName'].toString();
      photoUrl = widget.snap['photoUrl'].toString();
      state_of_block = widget.snap['state'].toString();
      previousMessage = widget.snap['previousMessage'].toString();
      if (previousMessage.length > 10) {
        previousMessage = previousMessage.substring(0, 9);
        previousMessage += "..";
      }
      int hold = widget.snap['timestamp'] ?? 0;
      hold *= -1;
      timestamp = hold.toString();

      uid = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
    });

    isBlocked = state_of_block == "blocked";

  }

  void toggleBlockState() async {
    final userDocRef = FirebaseFirestore.instance
        .collection('schools')
        .doc(widget.schoolName)
        .collection('users')
        .doc(uid)
        .collection('userMessaged')
        .doc(idTo);

    await userDocRef.update({
      'state': isBlocked ? "unblocked" : "blocked",
    }).then((value) {
      print('Document updated successfully');
    }).catchError((error) {
      print('Failed to update document: $error');
    });

    setState(() {
      isBlocked = !isBlocked;
    });
  }


  reportUser(String posterId) async {
    try {
      await FireStoreMethods().reportUser(widget.schoolName, posterId, uid);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockButtonText = isBlocked ? "Unblock User" : "Block User";
    final firebaseAuth = FirebaseAuth.instance;
    width = MediaQuery.of(context).size.width;
    if (idTo != "null") {
      return
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 1),
          child: TextButton(
            onPressed: () {
              if (KeyboardUtils.isKeyboardShowing()) {
                KeyboardUtils.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(
                            peerId: idTo ?? "",
                            peerAvatar: photoUrl,
                            peerNickname: peerName,
                            userAvatar: firebaseAuth.currentUser!.photoURL!,
                            schoolName: widget.schoolName,
                          ))).then((value) => setState(() {}));
            },
            child:
            Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                    leading: photoUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(Sizes.dimen_30),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  value: loadingProgress.expectedTotalBytes !=
                                      null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null),
                            );
                          }
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return const Icon(Icons.account_circle, size: 50);
                        },
                      ),
                    )
                        : const Icon(
                      Icons.account_circle,
                      size: 50,
                    ),
                    title: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              peerName,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          vertical5,
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(previousMessage + " ",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(DateFormat('MM/dd, hh:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(timestamp),
                                  ),
                                ),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ]
                    ),
                    trailing:
                    PopupMenuTheme(
                      data: PopupMenuThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                          color: Colors.white,
                          elevation: 3, // set the elevation to 0 to remove the shadow
                          ),
                          child: PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          PopupMenuItem(
                          value: 1,
                            child: GestureDetector(
                              onTap: () {
                                toggleBlockState();
                              },
                              child: Text(blockButtonText),
                            ),
                         ),
                          PopupMenuItem(
                            value: 2,
                            child: GestureDetector(
                              onTap: () {
                                reportUser(widget.snap['idTo'].toString());
                              },
                              child: Text('Report User'),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ),
                  vertical15,
                  Padding(
                    padding: EdgeInsets.fromLTRB(2, 0, 2, 3),
                    child: Container(
                      height:1.0,
                      width:width,
                      color:Colors.grey,
                    ) ,
                  ),
                ]
            ),
          ),
        );
    } else {
      return const SizedBox.shrink();
    }
  }

}