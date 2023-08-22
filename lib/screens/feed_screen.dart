import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allConstants/color_constants.dart';
import 'package:google_firebase_signin/allWidgets/saved_post_card.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/saved_posts.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';

class FeedScreen extends StatefulWidget {

  final String schoolName;
  // final bool isAdmin;
  const FeedScreen({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  // const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late DocumentReference _SchooldocRef;

  @override
  void initState() {
    super.initState();
    _SchooldocRef =
        FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
  }

  Future<bool> onBackPress() {

    return Future.value(false);
  }
  /**
   * builds feed for service hour opportunity posts
   */

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const webScreenSize = 600;

    return Scaffold(
      backgroundColor: Colors.white24,
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
          'Service Opportunities',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.spaceLight,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w200,
            fontSize: Sizes.dimen_24,
          ),
        ),
          actions: [

            IconButton(
              icon: const Icon(
                Icons.bookmark_border,
                color: Colors.black,

              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedPosts(schoolName: widget.schoolName)),
                );
              },

            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.black,

              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FixedUpPost(schoolName: widget.schoolName)),
                );
              },

            ),
          ]
      ),
      body:
      WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child:
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                    // margin: const EdgeInsets.all(5),
                    height: 47,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Sizes.dimen_30),
                        border: Border.all(color: AppColors.spaceLight)
                      // color: AppColors.spaceLight,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 10,
                        ),
                        Text(
                          widget.schoolName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Gilroy'),
                        ),
                      ],
                    ),
                  ),
                  // buildSearchBar(),
                  Expanded(
                    child:
                    StreamBuilder(
                      stream: _SchooldocRef.collection('posts').orderBy('postId').snapshots(),
                      // stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return

                            ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (ctx, index) =>
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                                      vertical: width > webScreenSize ? 15 : 0,
                                    ),
                                    child:

                                    PostCard(
                                      snap: snapshot.data!.docs[index].data(),
                                      isAdmin: false,
                                      schoolName: widget.schoolName,
                                    ),
                                  ),
                            );
                        } else {
                          return const Center(
                            child: Text('No current service posts...', style: TextStyle(fontFamily: 'Gilroy',),),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   child:
            //   isLoading ? const LoadingView() : const SizedBox.shrink(),
            // ),
          ],
        ),
      ),


    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataViaFuture() {
    return _SchooldocRef.collection("posts").orderBy("postId").get();
  }
}