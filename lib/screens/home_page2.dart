import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';
import 'package:google_firebase_signin/allWidgets/user_card.dart';
import 'package:google_firebase_signin/login/fluttter_engine_group.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/screens/alltutors.dart';
import 'package:google_firebase_signin/screens/goToTutors.dart';
import 'package:google_firebase_signin/screens/upload_post.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/loading_view.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/providers/home_provider.dart';
import 'package:google_firebase_signin/screens/chat_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/profile_page.dart';
import 'package:google_firebase_signin/utilities/debouncer.dart';
import 'package:google_firebase_signin/utilities/keyboard_utils.dart';
import 'dart:developer';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'chips.dart';

class HomePage2 extends StatefulWidget {

  final String schoolName;
  // final bool isAdmin;
  const HomePage2({
    Key? key,
    required this.schoolName,
  }) : super(key: key);


  // const HomePage2({Key? key}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

/**
 * homepage displaying all messaging between user and their tutors
 * also allowing users to click on their profile, tutors page, and log out
 */

class _HomePage2State extends State<HomePage2> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();
  late DocumentReference _SchooldocRef;
  //
  // DocumentReference _SchooldocRef =
  // FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);

  int x = 17;

  int _limit = 20;
  String holdContent = "";
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  bool checkLoading = false;
  late int numOfCurrentTutors = 0;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  int countNumMessaged = 0;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  /**
   * refreshes all state of page when swiped down
   */

  Future<void> _pullRefresh() async {
    setState(() {
      forAsync();
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  /**
   * logging out
   */

  Future<void> googleSignOut(String userId) async {

    // Future<void> googleSignOut(String userId) async {
    await authProvider.googleSignOut();
    await FirebaseAuth.instance.signOut();
    // await googleSignIn.disconnect();
    // await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FlutterEngineGroup()));

  }

  Future<bool> onBackPress() {

    if(x==_limit){
      x=15;

    }
//{567}
    openDialog();
    return Future.value(false);
  }

  /**
   * logging out
   */
  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: AppColors.burgundy,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Exit Application',
                  style: TextStyle(color: AppColors.white),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.dimen_10),
            ),
            children: [
              vertical10,
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: AppColors.white, fontSize: Sizes.dimen_16),
              ),
              vertical15,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(Sizes.dimen_8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: AppColors.spaceCadet),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }


  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  /**
   * initializing all varaibles
   */
  @override
  void initState() {
    super.initState();
    setState(() {});
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    _SchooldocRef =  FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => FlutterEngineGroup()),
              (Route<dynamic> route) => false);
    }

    scrollController.addListener(scrollListener);
    forAsync();
  }

  void forAsync() async {
    CollectionReference _collectionRef =
    _SchooldocRef.collection('users').doc(currentUserId).collection('userMessaged');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    numOfCurrentTutors = querySnapshot.size - 1;
  }

  @override
  Widget build(BuildContext context) {
    double widtth = MediaQuery.of(context).size.width;
    int widd = widtth.toInt();

    print(widtth);
    print("THIS IS THE WIEDTTHTHT");
    final width = MediaQuery.of(context).size.width;
    int webScreenSize = widd + 1;
    return Scaffold(
      appBar: AppBar(
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
          leading: IconButton(
              onPressed: () => googleSignOut(currentUserId),
              icon: const Icon(Icons.logout,    color: Colors.black, // Replace with your desired color
              )),// you can put Icon as well, it accepts any widget.
          title: const Text(
            'EdiFly',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_28,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GoToTutorsPage(schoolName: widget.schoolName)));
                },
                icon: const Icon(Icons.supervisor_account_rounded, size: 30, color: Colors.black, // Replace with your desired color
                )),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(schoolName: widget.schoolName)));
                },
                icon: const Icon(Icons.person, size: 30, color: Colors.black, // Replace with your desired color
                )),
          ]),
      body: RefreshIndicator(
        // color: Colors.white,
        onRefresh: _pullRefresh,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center, // Align however you like (i.e .centerRight, centerLeft)
              child: Visibility(
                visible: (numOfCurrentTutors == 0),
                child: Text("No current tutors...",           textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontFamily: 'Gilroy'),),
              ),
            ),
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.bold,
                          fontSize: Sizes.dimen_20,
                        ),
                      ),
                    ],
                  ),
                ),
                // buildSearchBar()
                Expanded(
                  child: FutureBuilder(
                    future: getDataViaFuture(),
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
                                child: UserCard(
                                  snap: snapshot.data!.docs[index].data(),
                                  isAdmin: false,
                                  schoolName: widget.schoolName,
                                ),
                              ),
                        );
                      } else {
                        String display = "";
                        Future.delayed(const Duration(milliseconds: 200), () {
                          display = "No current tutors...";
                          setState(() {});
                        });
                        return Center(
                          child: Text(display, style: TextStyle(fontFamily: 'Gilroy',),),
                        );
                      }
                    },
                  ),
                ),

              ],
            ),
            ),
            Positioned(
              child:
              isLoading ? const LoadingView() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataViaFuture() {
    return _SchooldocRef.collection("users").doc(currentUserId).collection('userMessaged').orderBy("timestamp").get();
  }

}

// notifications, UI,
// apple sign in