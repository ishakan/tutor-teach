import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/book_mark_animation.dart';
import 'package:google_firebase_signin/models/chat_user.dart' as model;
import 'package:google_firebase_signin/providers/chat_provider.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_firebase_signin/providers/user_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/screens/profile_page.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:google_firebase_signin/allWidgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class badMessageCard extends StatefulWidget {
  final snap;
  final schoolName;
  const badMessageCard({
    Key? key,
    required this.snap,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<badMessageCard> createState() => _badMessageCardState();
}

class _badMessageCardState extends State<badMessageCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLikeAnimating = false;
  static const webScreenSize = 600;
  late String currentUserId;
  String dialCodeDigits = '+00';
  String idFrom = "";
  String idTo = "";
  String content = "";
  late int timestamp;
  String nameFrom = "";
  String nameTo = "";
  String senderPhotoUrl = "", recieverPhotoUrl = "";
  String postId = "";


  /**
      Class used to create structure for admins to view bad messages sent between tutors and studnets.
      Allows administrators to see which students sent the bad message, who recieved, timestamp
   */

  @override
  void initState() {
    super.initState();
    forAsync();
    print("THIS SET VALUE VALUE2");
  }

  void forAsync() async {
    readLocal();


    print("THIS SET VALUE VALUE");
  }

  void readLocal() {
    setState(() {
      idFrom = widget.snap['idFrom'].toString();
      idTo = widget.snap['idTo'].toString();
      timestamp = widget.snap['timestamp'];
      content = widget.snap['content'].toString();
      nameFrom = widget.snap['nameFrom'].toString();
      senderPhotoUrl = widget.snap['senderPhoto'].toString();
      nameTo = widget.snap['nameTo'].toString();
      recieverPhotoUrl = widget.snap['recieverPhoto'].toString();
      postId = (timestamp * -1).toString();
    });
  }

  deleteBadMessage(String postId) async {
    try {
      await FireStoreMethods().deleteBadMessage(postId, widget.schoolName);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    late ProfileProvider user = context.read<ProfileProvider>();

    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white24,
        ),
        color: Colors.white24,
      ),
      padding: const EdgeInsets.fromLTRB(
        10, 10, 10, 2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffE4E4E4),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ).copyWith(right: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          6, 5, 0, 5,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      6, 2, 0, 5,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget> [
                                            Text(
                                              "Sender:     ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                senderPhotoUrl,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "   $nameFrom",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Gilroy",
                                                ),
                                                softWrap: false,
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.more_vert),
                                              onPressed: () {
                                                showDialog(
                                                  useRootNavigator: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return SimpleDialog(
                                                      children: <Widget>[
                                                        SimpleDialogOption(
                                                          padding: const EdgeInsets.all(20),
                                                          child: const Text("Delete Bad Message", style: TextStyle(fontFamily: 'Gilroy'),),
                                                          onPressed: () {
                                                            deleteBadMessage(postId);
                                                            setState(() {

                                                            });
                                                            showSnackBar(
                                                              context,
                                                              'Bad Message Removed. Refresh Page.',
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        vertical5,
                                        Row(
                                          children: <Widget> [
                                            Text(
                                              "Receiver:   ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                recieverPhotoUrl,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "   $nameTo",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Gilroy",
                                                ),
                                                softWrap: false,
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        vertical5,
                                        Row(
                                          children: <Widget> [
                                            Text(
                                              "Content: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "  $content",
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Gilroy",
                                                ),
                                                softWrap: false,
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        vertical10,
                                        Row(
                                          children: <Widget> [
                                            Text(
                                              "Timestamp: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            Expanded(
                                              child:  Text(
                                                DateFormat('dd MMM yyyy, hh:mm a').format(
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                    timestamp * -1,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Gilroy",
                                                ),
                                                softWrap: false,
                                                maxLines: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}