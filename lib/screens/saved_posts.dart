import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allConstants/color_constants.dart';
import 'package:google_firebase_signin/allWidgets/saved_post_card.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';
import 'package:provider/provider.dart';

class SavedPosts extends StatefulWidget {
  const SavedPosts({Key? key}) : super(key: key);

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {

  String uid = "";
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
    print("THIS SET VALUE VALUE2");
  }


  void readLocal() async {
    setState(() {
      uid = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      // print(bookState);
    });
    // print(bookState);
    // print(postId);
    // print("THIS SET VALUE VALUE2");
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const webScreenSize = 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: width > webScreenSize
          ? null
          : AppBar(
        elevation: 0,
        backgroundColor: AppColors.spaceCadet,
        centerTitle: false,
        title: const Text(
          'Saved Posts',
          style: TextStyle(color: Colors.white),
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.bookmark_border,
              color: primaryColor,

            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedPosts()),
              );
            },

          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: primaryColor,

            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FixedUpPost()),
              );
            },

          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('postId').snapshots(),
        // stream: FirebaseFirestore.instance.collection('posts').orderBy("timestamp").snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Map<String, dynamic> holder = snapshot.data!.docs[index].data();
          // List allIds = holder["bookMarked"];
          // if (allIds.contains(uid)) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: SavedPostCard(
                  snap: snapshot.data!.docs[index].data(),
                  isAdmin: false,
                ),
              ),
            );
          // }
          // else {
          //   return Container(
          //     width: 0,
          //     height: 0,
          //   )
          // }

        },
      ),
    );
  }
}