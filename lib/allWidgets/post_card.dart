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

class PostCard extends StatefulWidget {
  final snap;
  final isAdmin;
  final schoolName;
  const
  PostCard({
    Key? key,
    required this.snap,
    required this.isAdmin,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}


/**
    Structure for posts in service hour opportunity feed
 */

class _PostCardState extends State<PostCard> {

  late DocumentReference _SchooldocRef;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLikeAnimating = false;
  static const webScreenSize = 600;
  late String currentUserId;
  String dialCodeDigits = '+00';
  String id = '';
  String postId = '';
  String displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';
  String testing = '';
  String isTutor = "";
  String idFrom = "";
  String post_description = "";
  String timestamp = "";
  String post_title = "";
  String post_image = "";
  List likes = [];
  String uid = "";
  List bookMarkedPost = [];
  // late bool bookState = false;
  bool checKIfGood = true;
  String tester = "";

  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    _SchooldocRef =
        FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
    profileProvider = context.read<ProfileProvider>();
    forAsync();
    // print(bookState);
    print(postId);
    print("THIS SET VALUE VALUE2");
  }

  void forAsync() async {
    readLocal();
    // bookState = await FireStoreMethods().tellIfContained(uid, postId, widget.schoolName);
    // print(bookState);
    print(postId);
    print("THIS SET VALUE VALUE");
  }

  void readLocal() async {
    setState(() {
      id = widget.snap['idFrom'].toString();
      postId = widget.snap['postId'].toString();

      print("BOOK_MARK_STATUS");

      uid = profileProvider.getPrefs(FirestoreConstants.id) ?? "";


      if (widget.snap['post_title'] == null || widget.snap['displayName'] == null
        || widget.snap['idFrom'] == null || widget.snap['postId'] == null ||
        widget.snap['likes'] == null || widget.snap['timestamp'] == null ||
        widget.snap['bookMarked'] == null) {
        checKIfGood = false;
      }
    });
  }


  /**
      Function to delete post

      @param postId - identified post
   */


  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId, widget.schoolName);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }
  // Future<String> reportPost(String postId, String schoolName, String posterId, String uid) async {

  reportPost(String postId, String posterId) async {
    try {
      await FireStoreMethods().reportPost(postId, widget.schoolName, posterId, uid);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  /**
      Widget structure for posts
   */


  @override
  Widget build(BuildContext context) {
    if (!checKIfGood) {
      return Container(
        width: 0,
        height: 0,
      );
    } else {
      // print(bookState);
      print(postId);
      print("THIS SET VALUE3");
      late ProfileProvider user = context.read<ProfileProvider>();

      final width = MediaQuery.of(context).size.width;
      id = user.getPrefs(FirestoreConstants.id) ?? "";

      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white24,
          ),
          color: Colors.white24,
        ),
        padding: const EdgeInsets.fromLTRB(
          10, 12, 10, 2,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Color(0xffE4E4E4),
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),

          child: Container(
            // decoration: new BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
            // color: Color(0xffE4E4E4),
            child: Column(
              children: [
                // HEADER SECTION OF THE POST
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ).copyWith(right: 0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          widget.snap['photoUrl'].toString(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            6, 2, 0, 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget> [
                                  Text(
                                    widget.snap['displayName'].toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.fromLTRB(3, 1, 5, 0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.green,
                                      size: 15,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.snap['post_title'].toString(),
                                      style: TextStyle( color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                      softWrap: false,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis, // new
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                // title: const Text('Choose a photo'),
                                children: <Widget>[
                                  // SimpleDialogOption(
                                  //     padding: const EdgeInsets.all(20),
                                  //     child: const Text('Take a photo'),
                                  //     onPressed: () async {
                                  //       Navigator.pop(context);
                                  //       Uint8List file = await pickImage(ImageSource.camera);
                                  //       setState(() {
                                  //         _file = file;
                                  //       });
                                  //     }),
                                  Visibility(
                                    visible: (widget.snap['idFrom']
                                        .toString() == id || widget.isAdmin),
                                    child: SimpleDialogOption(
                                        padding: const EdgeInsets.all(20),
                                        child: const Text('Delete Post'),
                                        onPressed: () {
                                          deletePost(
                                            widget.snap['postId']
                                                .toString(),
                                          );
                                          showSnackBar(
                                            context,
                                            'Post Deleted.',
                                          );
                                        }),
                                  ),
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.all(20),
                                    child: const Text("Report Post"),
                                    onPressed: () {
                                      reportPost(
                                        widget.snap['postId']
                                            .toString(),
                                        widget.snap['idFrom']
                                            .toString(),
                                      );
                                      showSnackBar(
                                        context,
                                        'Post Reported.',
                                      );
                                    },
                                  )
                                ],
                              );
                            }
                        );
                      }
                  ),
                      // (widget.snap['idFrom'].toString() == id || widget.isAdmin)
                      //     ? IconButton(
                      //   onPressed: () {
                      //     showDialog(
                      //       useRootNavigator: false,
                      //       context: context,
                      //       builder: (context) {
                      //         return Dialog(
                      //           child: ListView(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 16),
                      //               shrinkWrap: true,
                      //               children: [
                      //                 'Delete',
                      //               ]
                      //                   .map(
                      //                     (e) => InkWell(
                      //                     child: Container(
                      //                       padding:
                      //                       const EdgeInsets.symmetric(
                      //                           vertical: 12,
                      //                           horizontal: 16),
                      //                       child: Text(e),
                      //                     ),
                      //                     onTap: () {
                      //                       deletePost(
                      //                         widget.snap['postId']
                      //                             .toString(),
                      //                       );
                      //                       // remove the dialog box
                      //                       Navigator.of(context).pop();
                      //                     }),
                      //               )
                      //                   .toList()),
                      //         );
                      //       },
                      //     );
                      //   },
                      //   icon: const Icon(Icons.more_vert),
                      // )
                      //     : IconButton(
                      //   onPressed: () {
                      //   },
                      //   icon: const Icon(null),
                      // ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: ' ${widget.snap['post_description']}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   child: Text(
                      //     widget.snap['timestamp'].toString(),
                      //     style: const TextStyle(
                      //       color: secondaryColor,
                      //     ),
                      //   ),
                      //   padding: const EdgeInsets.symmetric(vertical: 2),
                      // ),
                    ],
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    FireStoreMethods().likePost(
                      widget.snap['postId'].toString(),
                      id,
                      widget.snap['likes'],
                      widget.schoolName,
                    );
                    setState(() {
                      isLikeAnimating = true;
                    });
                  },

                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: widget.snap['post_image'].toString() == "None" ?
                        const SizedBox(
                          width: 0,
                          height: 0,
                        ) :
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            widget.snap['post_image'].toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isLikeAnimating ? 1 : 0,
                        child: LikeAnimation(
                          isAnimating: isLikeAnimating,
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          onEnd: () {
                            setState(() {
                              isLikeAnimating = false;
                            });
                          },
                          child: widget.snap['post_image'].toString() == "None" ?
                          const Icon(
                            Icons.thumb_up,
                            color: Colors.white,
                            size: 0,
                            // size: 100,
                          ) :
                          const Icon(
                            Icons.thumb_up,
                            color: Colors.white,
                            size: 100,
                            // size: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.snap['timestamp'].toString(),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                        // padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                    ]
                  ),
                ),
                // LIKE, COMMENT SECTION OF THE POST
                SizedBox(
                  width: width, // set this
                  child:
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 8, 2),
                    child:
                    Column(
                      children: [
                        Row(
                          children: <Widget>[
                            DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(fontWeight: FontWeight.w800),
                                child: Text(
                                  (widget.snap['likes'].length == 1) ?
                                  '${widget.snap['likes'].length} like' :
                                  '${widget.snap['likes'].length} likes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: Sizes.dimen_14),
                                  // style: Theme.of(context).textTheme.bodyText2,
                                )),
                            LikeAnimation(
                              isAnimating: widget.snap['likes'].contains(id),
                              smallLike: true,
                              child: IconButton(
                                icon: widget.snap['likes'].contains(id)
                                    ? const Icon(
                                  Icons.thumb_up_alt,
                                  color: Colors.blueAccent,
                                )
                                    : const Icon(
                                  Icons.thumb_up_alt_outlined,
                                ),
                                onPressed: () => FireStoreMethods().likePost(
                                  widget.snap['postId'].toString(),
                                  id,
                                  widget.snap['likes'],
                                  widget.schoolName,
                                ),
                              ),
                            ),
                            Column(
                                children: [
                                  Visibility(
                                      visible: !widget.isAdmin,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, 8, 2),
                                        child:
                                        BookMarkAnimation(
                                          isAnimating: widget.snap['bookMarked'].contains(id),
                                          smallLike: true,
                                          child: IconButton(
                                            icon: widget.snap['bookMarked'].contains(id)
                                                ? const Icon(
                                              Icons.bookmark,
                                              color: Colors.black,
                                            )
                                                : const Icon(
                                              Icons.bookmark_border,
                                            ),
                                            onPressed: () => FireStoreMethods().bookMarkPost(
                                              widget.snap['postId'].toString(),
                                              id,
                                              widget.snap['bookMarked'],
                                              widget.schoolName,
                                            ),
                                          ),
                                        ),
                                        // ],
                                      ),
                                  ),
                                ]
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                ),
                //DESCRIPTION AND NUMBER OF COMMENTS
              ],
            ),
          ),
        ),
      );
    }
  }
}