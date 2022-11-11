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

class TutorCard extends StatefulWidget {
  final snap;
  final isAdmin;
  const TutorCard({
    Key? key,
    required this.snap,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<TutorCard> createState() => _TutorCardState();
}

class _TutorCardState extends State<TutorCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLikeAnimating = false;
  static const webScreenSize = 600;
  late String currentUserId;
  String idTo = "";
  String peerName = "";
  String photoUrl = "";
  String previousMessage = "";
  String timestamp = "";
  double width = 0.0;
  String uid = "";
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
    print("THIS SET VALUE VALUE2");
  }

  void readLocal()  {
    setState(() {
      idTo = widget.snap['idTo'].toString();
      peerName = widget.snap['peerName'].toString();
      photoUrl = widget.snap['photoUrl'].toString();
      previousMessage = widget.snap['previousMessage'].toString();
      int hold = widget.snap['timestamp'] ?? 0;
      hold *= -1;
      timestamp = hold.toString();

      uid = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      // print(bookState);

    });
    // print(bookState);
    // print(postId);
    // print("THIS SET VALUE VALUE2");
  }

  @override
  Widget build(BuildContext context) {
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
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Column(
                children: [
                  ListTile(
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
                                child: Text(previousMessage,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: width - 160,
                                child:
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    DateFormat('MM/dd, hh:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(timestamp),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]
                    ),
                  ),
                  vertical15,
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 3),
                    child: Container(
                      height:1.0,
                      width:width,
                      color:Colors.grey,
                    ) ,
                  )

                  // Divider(
                  //     color: Colors.black
                  // )
                ]
            ),
            ),
          ),
        );
    } else {
      return const SizedBox.shrink();
    }
  }

}