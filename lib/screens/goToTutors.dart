import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/login/fluttter_engine_group.dart';
import 'package:google_firebase_signin/screens/home_page2.dart';
import 'package:google_firebase_signin/screens/scienceFeed.dart';
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

class GoToTutorsPage extends StatefulWidget {
  // const GoToTutorsPage({Key? key}) : super(key: key);
  final String schoolName;

  const GoToTutorsPage({
    Key? key,
    required this.schoolName,

  }) : super(key: key);


  @override
  State<GoToTutorsPage> createState() => _GoToTutorsPageState();
}

/**
 * page to go to tutors for specific subject
 */


class _GoToTutorsPageState extends State<GoToTutorsPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  // static const bool holdIsAdmin = widget.isAdmin;
  int _limit = 100;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  String subjects = "subjects";

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>  FlutterEngineGroup()));
  }

  Future<bool> onBackPress() {
    return Future.value(false);
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  /**
   * initialzes all necessary varaibles
   */

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => FlutterEngineGroup()),
              (Route<dynamic> route) => false);
    }

    scrollController.addListener(scrollListener);
    // holdIsAdmin = widget.isAdmin;
  }

  /**
   * crates different styles for each subject
   */


  @override
  Widget build(BuildContext context) {

    final ButtonStyle style =
    ElevatedButton.styleFrom(elevation: 0.0, primary: Colors.white,
        side: BorderSide(width: 2.0, color: Colors.red,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
        minimumSize: const Size.fromHeight(100), // NEW
        textStyle: const TextStyle(fontSize: 20) );

    final ButtonStyle style2 =
    ElevatedButton.styleFrom(elevation: 0.0, primary: Colors.white,
        side: BorderSide(width: 2.0, color: Colors.yellow,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
        minimumSize: const Size.fromHeight(100), // NEW
        textStyle: const TextStyle(fontSize: 20) );

    final ButtonStyle style3 =
    ElevatedButton.styleFrom(elevation: 0.0, primary: Colors.white,
        side: BorderSide(width: 2.0, color: Colors.blue,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
        minimumSize: const Size.fromHeight(100), // NEW
        textStyle: const TextStyle(fontSize: 20) );

    final ButtonStyle style4 =
    ElevatedButton.styleFrom(elevation: 0.0, primary: Colors.white,
        side: BorderSide(width: 2.0, color: Colors.orange,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
        minimumSize: const Size.fromHeight(100), // NEW
        textStyle: const TextStyle(fontSize: 20) );

    final ButtonStyle style5 =
    ElevatedButton.styleFrom(elevation: 0.0, primary: AppColors.grayBackground,
        side: BorderSide(width: 2.0, color: Colors.green,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
        minimumSize: const Size.fromHeight(100), // NEW
        textStyle: const TextStyle(fontSize: 20) );

    /**
     * builds widgets for each subject
     */

    return Scaffold(
        backgroundColor: Colors.white, // Set the background color to white
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Set the height of the line
            child: Container(
              color: AppColors.greyColor, // Set the color of the line
              height: 1.0, // Set the height of the line
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black,)), // you can put Icon as well, it accepts any widget.
          title: const Text(
            'All Tutors',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_28,
            ),
          ),
          // const Text('All Tutors'),
        ),
        body: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    vertical25,
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: ElevatedButton(
                        style: style,
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) =>
                                scienceFeedScreen(fieldColors: [Color(0xff870000), Color(0xffE70000), Color(0xffFF6464),
                                  Color(0xffD75B00), Color(0xffFF6C00), Color(0xffFFA25D), Color(0xffE8BE00), Color(0xffFFDF4C), Color(0xffFFF74C),
                                  Color(0xffFF5593), Color(0xffFFA3C4), Color(0xffFFDBA3), Color(0xffFFC0A3), Color(0xffCB7D37), Color(0xff9E5747)],
                                    type: "Science",
                                    schoolName: widget.schoolName,)));
                        },
                        child: Wrap(
                          children: <Widget>[
                            Icon(
                              Icons.science_outlined,
                              color: Colors.red,
                              size: 24.0,
                            ),

                            SizedBox(
                              width:10,
                            ),
                            Text("Science", style:TextStyle(fontSize:22, color: Colors.red, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: ElevatedButton(
                        style: style2,
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => scienceFeedScreen(fieldColors: [Color(0xffCC9D22), Color(0xffFFC11F), Color(0xffFFDF8D),
                            Color(0xffD4DB3D), Color(0xffEFF90C), Color(0xffFBFFA0), Color(0xff8BAE22), Color(0xffADE014), Color(0xffE2FF8A),
                            Color(0xffD88A0D), Color(0xffFFB237), Color(0xffFFCC7B), Color(0xffFFD48F), Color(0xffC4A065), Color(0xffDCC900)],
                              type: "Math",
                             schoolName: widget.schoolName,)));
                        },
                        child: Wrap(
                          children: <Widget>[
                            Icon(
                              Icons.calculate_outlined,
                              color: Colors.yellow,
                              size: 24.0,
                            ),
                            SizedBox(
                              width:10,
                            ),
                            Text("Math", style:TextStyle(fontSize:22, color: Colors.yellow, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: ElevatedButton(
                        style: style3,
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => scienceFeedScreen(fieldColors: [Color(0xff318B94), Color(0xff2AAAB6), Color(0xff28CFDF),
                            Color(0xff79F3FF), Color(0xff001B8A), Color(0xff4867E7), Color(0xff1A38B6), Color(0xff869BF1), Color(0xff5A7EA2),
                            Color(0xff006DD9), Color(0xff0985FF), Color(0xff78BCFF), Color(0xffC3E1FF), Color(0xff1D9DA4), Color(0xff22DBE5)],
                              type: "Literature", schoolName: widget.schoolName,)));
                        },
                        child: Wrap(
                          children: <Widget>[
                            Icon(
                              Icons.library_books_outlined ,
                              color: Colors.blue,
                              size: 24.0,
                            ),
                            SizedBox(
                              width:10,
                            ),
                            Text("Literature", style:TextStyle(fontSize:22, color: Colors.blue, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: ElevatedButton(
                        style: style4,
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => scienceFeedScreen(fieldColors: [Color(0xffF0B277), Color(0xff944800), Color(0xffC8710E),
                            Color(0xffCA8D54), Color(0xffFF6C00), Color(0xffF68C13), Color(0xffFFCE95), Color(0xffE7A100), Color(0xffFFD472),
                            Color(0xffF1BF07), Color(0xffF3D97A), Color(0xffFFDBA3), Color(0xffEAE1C0), Color(0xffF7E610), Color(0xffFBD26C)],
                              type: "Language", schoolName: widget.schoolName,)));
                        },
                        child: Wrap(
                          children: <Widget>[
                            Icon(
                              Icons.language_outlined,
                              color: Colors.orange,
                              size: 24.0,
                            ),
                            SizedBox(
                              width:10,
                            ),
                            Text("Language", style:TextStyle(fontSize:22, color: Colors.orange, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: ElevatedButton(
                        style: style5,
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => scienceFeedScreen(fieldColors: [Color(0xff478E5C), Color(0xff3CAD5E), Color(0xff31D663),
                            Color(0xff34F400), Color(0xffBAF778), Color(0xffDAFFB1), Color(0xff005D08), Color(0xff038F0F), Color(0xff739175),
                            Color(0xffA7C6A9), Color(0xffB6F7BA), Color(0xff4AC38A), Color(0xff7AEDB7), Color(0xff7AEDC3), Color(0xffC0FAE5)],
                              type: "Humanities", schoolName: widget.schoolName)));
                        },
                        child: Wrap(
                          children: <Widget>[
                            Icon(
                              Icons.history_edu_outlined ,
                              color: Colors.green,
                              size: 24.0,
                            ),
                            SizedBox(
                              width:10,
                            ),
                            Text("Humanities", style:TextStyle(fontSize:22, color: Colors.green, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // child: Wrap(
                        //   children: <Widget>[
                        //     Icon(
                        //       Icons.history_edu_outlined,
                        //       color: Colors.green,
                        //       size: 24.0,
                        //     ),
                        //     SizedBox(
                        //       width:10,
                        //     ),
                        //     Text("Humanities", style:TextStyle(fontSize:22, color: Colors.green, fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                        //   ],
                        // ),
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
        ));
  }

}

