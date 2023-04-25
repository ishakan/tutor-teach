import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allConstants/color_constants.dart';
import 'package:google_firebase_signin/allWidgets/badMessageCard.dart';
import 'package:google_firebase_signin/allWidgets/saved_post_card.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/goToTutors.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/saved_posts.dart';
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
          : AppBar(
        elevation: 0,
        backgroundColor: AppColors.spaceCadet,
        centerTitle: false,
        title: const Text(
          'Bad Messages',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () => googleSignOut(),
            icon: const Icon(Icons.logout)), //
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GoToTutorsPage(schoolName: widget.schoolName,)));
                },
                icon: const Icon(Icons.supervisor_account_rounded)),
          ],
      ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}