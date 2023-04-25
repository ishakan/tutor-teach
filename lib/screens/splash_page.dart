import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen_admin.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/home_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    bool isAdmin = false;
    String schoolName = "";
    print(isLoggedIn);

    if (isLoggedIn) {

      LinkedHashMap<String, dynamic>? schools;
      DocumentReference documentReference = FirebaseFirestore.instance.collection('allUsers').doc(authProvider.getFirebaseUserId());
      await documentReference.get().then((snapshot) {
        print(snapshot.data());
        if (snapshot.data() != null) {
          schools = snapshot.data() as LinkedHashMap<String, dynamic>;
          schoolName = schools!["schoolName"];
        }
      });
      print("SCHOOLLL ");
      print(schoolName);
      String email = await authProvider.getFirebaseEmail(schoolName);
      print(email);

      LinkedHashMap<String, dynamic>? holdsData;

      var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('allowed_email');
      var docSnapshot = await collection.doc('allowed_email').get();
      List<dynamic> holder = [];
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        print(data);
        holder = data!['emails'] as List<dynamic>;
      }

      print("is Admin??");

      isAdmin = holder.contains(email);
    }

    if (isLoggedIn && isAdmin) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => bottomBarScreenAdmin(schoolName: schoolName,)));
      return;
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => bottomBarScreen(schoolName: schoolName,)));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  /**
   * Splash screens while app is loading
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Welcome to EdiFly",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
            ),
            Image.asset(
              'assets/images/splash.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Smart Chat Application",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: AppColors.lightGrey,
            ),
          ],
        ),
      ),
    );
  }
}
