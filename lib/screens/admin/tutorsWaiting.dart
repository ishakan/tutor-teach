import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';
import 'package:google_firebase_signin/allWidgets/user_card.dart';
import 'package:google_firebase_signin/allWidgets/waitingTutorsCard.dart';
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

import '../chips.dart';

class tutorsWaiting extends StatefulWidget {

  final String schoolName;
  // final bool isAdmin;
  const tutorsWaiting({
    Key? key,
    required this.schoolName,
  }) : super(key: key);


  // const HomePage2({Key? key}) : super(key: key);

  @override
  State<tutorsWaiting> createState() => _tutorsWaitingState();
}

/**
 * homepage displaying all messaging between user and their tutors
 * also allowing users to click on their profile, tutors page, and log out
 */

class _tutorsWaitingState extends State<tutorsWaiting> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();
  late DocumentReference _SchooldocRef;
  //
  // DocumentReference _SchooldocRef =
  // FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);

  int x = 17;
  int _selectedIndex = 0;

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



  /**
   * logging out
   */


  Future<bool> onBackPress() {

    if(x==_limit){
      x=15;

    }
//{567}
//     openDialog();
    return Future.value(false);
  }

  /**
   * logging out
   */
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
  //
  // void toggleState() {
  //   if (scrollController == true) {
  //     setState(() {
  //        buttonClearController.close();
  //     });
  //   }
  // }

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
          MaterialPageRoute(builder: (context) =>  FlutterEngineGroup()),
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
    print("THIS IS THE WIDTTHTHT");
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
          title: const Text(
            'Tutors in Waiting',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_24,
            ),
          ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child:
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.center, // Align however you like (i.e .centerRight, centerLeft)
                  child: Visibility(
                    visible: (numOfCurrentTutors == 0),
                    child: Text("No current tutors in waiting...",           textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontFamily: 'Gilroy'),),
                  ),
                ),
              ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              //   // margin: const EdgeInsets.all(5),
              //   height: 47,
              //   // decoration: BoxDecoration(
              //   //     color: Colors.white,
              //   //     borderRadius: BorderRadius.circular(Sizes.dimen_30),
              //   //     border: Border.all(color: AppColors.spaceLight)
              //   //   // color: AppColors.spaceLight,
              //   // ),
              //   // child: Column(
              //   //   children: [
              //   //     SizedBox(
              //   //       width: double.infinity,
              //   //       height: 10,
              //   //     ),
              //   //     Text("Tutors in Waiting",
              //   //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   //     ),
              //   //   ],
              //   // ),
              // ),
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
                              child: waitingTutorsCard(
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
          // Positioned(
          //   child:
          //   isLoading ? const LoadingView() : const SizedBox.shrink(),
          // ),
        ],
      ),
    );
  }
  //
  // Future<QuerySnapshot<Map<String, dynamic>>> getDataViaFuture() {
  //   return _SchooldocRef.collection("waiting").orderBy("databaseid_stored").get();
  // }

  Future<QuerySnapshot<Map<String, dynamic>>> getDataViaFuture() {
    return _SchooldocRef.collection("waiting").orderBy("databaseid_stored").get();
  }

}

