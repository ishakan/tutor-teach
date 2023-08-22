import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allConstants/color_constants.dart';
import 'package:google_firebase_signin/allWidgets/badMessageCard.dart';
import 'package:google_firebase_signin/allWidgets/saved_post_card.dart';
import 'package:google_firebase_signin/login/fluttter_engine_group.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/admin/tutorsWaiting.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/goToTutors.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/saved_posts.dart';
import 'package:google_firebase_signin/screens/waitingTutorsScreen.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';
import 'package:provider/provider.dart';


class BadMessagesScreen extends StatefulWidget {
  final String schoolName;
  const BadMessagesScreen({
    Key? key,
    required this.schoolName,
  }) : super(key: key);
  // const BadMessagesScreen({Key? key}) : super(key: key);

  @override
  State<BadMessagesScreen> createState() => _BadMessagesScreenState();
}

class _BadMessagesScreenState extends State<BadMessagesScreen> {
  late AuthProvider authProvider;

  late DocumentReference _SchooldocRef;

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    // await authProvider.googleSignOut();
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FlutterEngineGroup()));
    //
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    _SchooldocRef = FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
    authProvider = context.read<AuthProvider>();
  }

  /**
   * feed builder for bad mesages shown to the adminstrator, StreamBuilder
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
            'Bad Messages',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_24,
            ),
          ),
        leading: IconButton(
            onPressed: () => googleSignOut(),
            icon: const Icon(Icons.logout, color: Colors.black,)), //
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => tutorsWaiting(schoolName: widget.schoolName,)));
              },
              icon: const Icon(Icons.person_add, color: Colors.black,)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GoToTutorsPage(schoolName: widget.schoolName,)));
              },
              icon: const Icon(Icons.supervisor_account_rounded, color: Colors.black,)),
        ],
      ),

      // AppBar(
      //   elevation: 0,
      //   backgroundColor: AppColors.spaceCadet,
      //   centerTitle: false,
      //   title: const Text(
      //     'Bad Messages',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   leading: IconButton(
      //       onPressed: () => googleSignOut(),
      //       icon: const Icon(Icons.logout)), //
      //     actions: [
      //       IconButton(
      //           onPressed: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => tutorsWaiting(schoolName: widget.schoolName,)));
      //           },
      //           icon: const Icon(Icons.person_add)),
      //       IconButton(
      //           onPressed: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => GoToTutorsPage(schoolName: widget.schoolName,)));
      //           },
      //           icon: const Icon(Icons.supervisor_account_rounded)),
      //     ],
      // ),
      body: StreamBuilder(
        stream: _SchooldocRef.collection('bad_messages').orderBy("timestamp").snapshots(),
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
              child: badMessageCard(
                snap: snapshot.data!.docs[index].data(),
                schoolName: widget.schoolName,
              ),
            ),
          );
        },
      ),
    );
  }
}
