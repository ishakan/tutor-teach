import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allConstants/color_constants.dart';
import 'package:google_firebase_signin/allWidgets/saved_post_card.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/saved_posts.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const webScreenSize = 600;

    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: width > webScreenSize
          ? null
          : AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.spaceCadet,
        centerTitle: false,
        title: const Text(
          'Service Opportunities',
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
    //   body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>> (
    //     builder: (_, snapshot) {
    // if (snapshot.hasData) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //       return ListView.builder(
    //         itemCount: snapshot.data!.docs.length,
    //         itemBuilder: (_, index) =>
    //             Container(
    //               margin: EdgeInsets.symmetric(
    //                 horizontal: width > webScreenSize ? width * 0.3 : 0,
    //                 vertical: width > webScreenSize ? 15 : 0,
    //               ),
    //               child: PostCard(
    //                 snap: snapshot.data!.docs[index].data(),
    //                 isAdmin: false,
    //               ),
    //             ),
    //       );
    //     } else {
    //       return const Center(
    //         child: Text('No current service posts...'),
    //       );
    //     }
    //     },
    //     future: getDataViaFuture(),
    //   )
    //   body: FutureBuilder(
    //     future: getDataViaFuture(),
    //     builder: (context,
    //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    //       if (snapshot.hasData) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return const Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         }
    //         return ListView.builder(
    //           itemCount: snapshot.data!.docs.length,
    //           itemBuilder: (ctx, index) =>
    //               Container(
    //                 margin: EdgeInsets.symmetric(
    //                   horizontal: width > webScreenSize ? width * 0.3 : 0,
    //                   vertical: width > webScreenSize ? 15 : 0,
    //                 ),
    //                 child: PostCard(
    //                   snap: snapshot.data!.docs[index].data(),
    //                   isAdmin: false,
    //                 ),
    //               ),
    //         );
    //       } else {
    //         return const Center(
    //           child: Text('No current service posts...'),
    //         );
    //       }
    //     },
    //   ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('postId').snapshots(),
        // stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) =>
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                    snap: snapshot.data!.docs[index].data(),
                    isAdmin: false,
                  ),
                ),
          );
        } else {
          return const Center(
            child: Text('No current service posts...'),
          );
        }
        },
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataViaFuture() {
    return FirebaseFirestore.instance.collection("posts").orderBy("postId").get();
  }
}