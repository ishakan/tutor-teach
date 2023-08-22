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
  // const SavedPosts({Key? key}) : super(key: key);
  final String schoolName;
  // final bool isAdmin;
  const SavedPosts({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

/**
 * builds page for saved posts for users
 */


class _SavedPostsState extends State<SavedPosts> {
  late DocumentReference _SchooldocRef;
  String uid = "";
  late ProfileProvider profileProvider;
  late int numOfSsavedPosts = 0;
  bool holdStatus = false;


  @override
  void initState() {
    super.initState();
    setState(() {
      profileProvider = context.read<ProfileProvider>();
      uid = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      finishFunction();
    });
  }

  void finishFunction() async {
    await forAsync();
    setState(() {
      print(numOfSsavedPosts);
    });
  }

  Future<void> forAsync() async {
    _SchooldocRef = FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
    int counter = 0;
    QuerySnapshot querySnapshot = await _SchooldocRef.collection("posts").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      LinkedHashMap<dynamic, dynamic> data = querySnapshot.docs[i].data() as LinkedHashMap<dynamic, dynamic>;
      if (data["bookMarked"] != null) {
        List<dynamic> allbooksmarkedUsers = data["bookMarked"] ?? {};
        if (allbooksmarkedUsers.contains(uid)) {
          counter++;
        }
      }
    }
    numOfSsavedPosts = counter;
  }

  Future<bool> onBackPress() {
    return Future.value(false);
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const webScreenSize = 600;
    print(numOfSsavedPosts);
    print("svaed posts");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: width > webScreenSize
          ? null
          :
      AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Set the height of the line
            child: Container(
              color: AppColors.greyColor, // Set the color of the line
              height: 1.0, // Set the height of the line
            ),
          ),
          title: const Text(
            'Saved Posts',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_24,
            ),
          ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back), color: Colors.black,),
      ),

      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center, // Align however you like (i.e .centerRight, centerLeft)
              child: Visibility(
                visible: (numOfSsavedPosts == 0),
                child: Text("No posts currently saved...",           textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('schools').doc(widget.schoolName).collection('posts').orderBy('postId').snapshots(),
                    // stream: FirebaseFirestore.instance.collection('posts').orderBy("timestamp").snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
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
                            schoolName: widget.schoolName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}