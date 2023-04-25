import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/loading_view.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/providers/home_provider.dart';
import 'package:google_firebase_signin/screens/chat_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/utilities/debouncer.dart';
import 'package:google_firebase_signin/utilities/keyboard_utils.dart';

class scienceFeedScreen extends StatefulWidget {
  // const scienceFeedScreen({Key? key}) : super(key: key);
  final List<Color> fieldColors;
  final String type;
  final String schoolName;
  // final bool isAdmin;
  const scienceFeedScreen({
    Key? key,
    required this.fieldColors,
    required this.type,
    required this.schoolName,
  }) : super(key: key);

  @override
  State<scienceFeedScreen> createState() => _scienceFeedScreenState();
}

/**
 * creates lists of all tutors for any course under any subject
 */


class _scienceFeedScreenState extends State<scienceFeedScreen> {
  // var collection = FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('subjects');
  late final Future<DocumentSnapshot> _calculation;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();
  String peerId = "", peerName = "", peerPhotoUrl = "", gradeLevel = "", fcmToken = "";
  late ProfileProvider profileProvider;

  int _limit = 100;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  String subjects = "subjects";
  bool currentStatus = false;
  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  // Widget holdCompSci = Container();
  List<String> allScienceClasses = [];
  bool isAdmin = false;

  List<Widget> displayAllScience = [];
  Widget displayCompSci = Container();
  Widget displayBio = Container();

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
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

  @override
  void initState()  {
    super.initState();
    asyncFunction();
    // checkIfAdmin();
  }

  /**
   * gets all classes
   */


  Future<void> getScienceClasses() async {

    print("Begin");
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('subjects').get();
    
    for (int i = 0; i < snapshot.docs.length; i++) {
      Map<String, dynamic> allData = snapshot.docs[i].data();
      if (allData["type"] == widget.type) {
        allScienceClasses.add(snapshot.docs[i].id);
      }
    }
    print(allScienceClasses);
    print("Science Classes?");

  }

  void asyncFunction() async {
    await getScienceClasses();
    for (int i =0; i < allScienceClasses.length; i++) {
      print(allScienceClasses[i]);
      displayCompSci = await buildEntireSubject(allScienceClasses[i], widget.fieldColors[i]);
      displayAllScience.add(displayCompSci);
    }
    readLocal();
    checkIfAdmin();
    currentStatus = true;

    print(currentStatus);

  }

  /**
   * determines if user is an admine, will change whether user can message tutors or not
   */

  void checkIfAdmin() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('allowed_email').get();
    List<dynamic> holder = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      Map<String, dynamic> allData = snapshot.docs[i].data();
      holder = allData["emails"];
    }
    print(holder);

    DocumentReference documentReference = FirebaseFirestore.instance.collection('schools').doc(widget.schoolName).collection('users').doc(currentUserId);
    await documentReference.get().then((snapshot2) {
      print(snapshot2.data());
      Map<String, dynamic> allData = snapshot2.data() as Map<String, dynamic>;

    });
    //
    // print("Begin");
    // DocumentSnapshot<Map<String, dynamic>> snapshot2 = await FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('users').doc(currentUserId).get();
    //
    // print(allData);
    // print(allScienceClasses);
    print("Science Classes?");

    String email = await authProvider.getFirebaseEmail(widget.schoolName);
    // String email = profileProvider.getPrefs(FirestoreConstants.email) ?? "";
    print(email);
    print("EMAIL?");
    if (holder.contains(email)) {
      isAdmin = true;
    }
    print(isAdmin);
  }


  void readLocal() async {
    setState(() {
      profileProvider = context.read<ProfileProvider>();
      authProvider = context.read<AuthProvider>();
      homeProvider = context.read<HomeProvider>();
      if (authProvider
          .getFirebaseUserId()
          ?.isNotEmpty == true) {
        currentUserId = authProvider.getFirebaseUserId()!;
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false);
      }
    });
    print("finished read Local");
    print(currentStatus);

    // print(holdCompSci);
    print("HOLD COMP SCI");
    scrollController.addListener(scrollListener);
    print("IS ADMIN??");

  }



  @override
  Widget build(BuildContext context) {
    print(currentStatus);
    print("CURRENT STATUS");
    return (!currentStatus) ? Scaffold(
      body:
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "EdiFly",
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
              "Tutors",
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
    )  :
    Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back)), // you can put Icon as well, it accepts any widget.
          title: Text('${widget.type} Tutors'),
        ),
        body: WillPopScope(
          onWillPop: onBackPress,
          child:

          Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: displayAllScience,
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

  Future<String> getName(String name) async {
      var collection = FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('subjects');
      var docSnapshot = await collection.doc(name).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        print(data);
        return data!["displayName"];
        print("getDataForSubject");
      } return "";
  }

  /**
   * title displaying course name
   */

  Widget buildTitle(String input, Color subColor) {
    input = input.replaceAll('_', " ");
    print(input.replaceAll("_", " "));
    print("replaced");
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // <= No more error here :)
        color: subColor,
      ),
      height: 25,
      width: MediaQuery.of(context).size.width,
      child: Text(input,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          wordSpacing: 2,
        ),
      ),
    );
  }

  /**
   * shows both title and tutors listed for each course
   * @params input - course name, subColor - course color
   */

  Future<Widget> buildEntireSubject(String input, Color subColor) async {
    List<Widget> holder = await buildTutorsforSubject(input, subColor);
    return Container(
      margin: const EdgeInsets.all(15.0),
      decoration:  BoxDecoration(
          border: Border.all(width:2.0,
            color: subColor,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),

      child: (holder.length > 0) ?
        Column(
            children: [
              buildTitle(input, subColor),
              Column(
                children: holder,
              )
            ]
        ) :
        Column(
            children: [
              buildTitle(input, subColor),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text("No Current Tutors",  style: const TextStyle(color: Colors.grey, fontSize: 15)),
              ),
            ]
        ),
    );
  }

  /**
   * gathers all tutors for course from Frebase Database
   */

  Future<List<Widget>> buildTutorsforSubject(String input, Color color) async {
    String subjects = "subjects";
    List<Widget> children = [];
    List<dynamic> allID = [];
    var collection = FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('subjects');
    var docSnapshot = await collection.doc(input).get();
    print("INPUT");
    print(docSnapshot);
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = {};
      data = docSnapshot.data();
      print(data);
      print("THIS DATA");
      print(data![input]);
      allID = data[input] as List<dynamic>;
      print(allID);
    }

    // holdCompTutors.add(buildTitle(input, color));
    // holdCompTutors.add(vertical15);
    var u_collection = FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('users');
    print(u_collection);
    for (int i =0; i < allID.length; i++) {
        if (allID[i] != "") {
          print(allID[i]);
          print("ALL ID");
          bool isGood = true;
          DocumentReference documentReference = FirebaseFirestore.instance.collection("schools").doc(widget.schoolName).collection('users').doc(allID[i]);
          print(documentReference);
          await documentReference.get().then((snapshot) {
            if (snapshot.data() == null) {
              isGood = false;
            } else {
              LinkedHashMap<String, dynamic>? data = snapshot.data() as LinkedHashMap<String, dynamic>;
              peerId = data["id"] ?? "";
              print(peerId);
              peerName = data["displayName"] ?? "";
              peerPhotoUrl = data["photoUrl"] ?? "";
              gradeLevel = data["aboutMe"] ?? "";
              fcmToken = data["fcmToken"] ?? "";
            }
          });

          print(peerId);
          print(peerName);
          print(peerPhotoUrl);
          print(gradeLevel);
          print(fcmToken);
          print("ALL THINGS");
          if (isGood && peerId.length > 0) {
            children.add(
                buildItem(context, peerId, peerName, peerPhotoUrl, gradeLevel, fcmToken));
          }
        }
    }
    return children;
    print("HOLD COMP TUTORS2");
    // print(children);
    // return children;
  }

  // void setCalculation(String input) async {
  //   _calculation = collection.doc(input).get();
  // }

  Widget buildItem(BuildContext context, String peerId, String peerName, String peerPhotoUrl, String gradeLevel, String fcmToken)  {
    final firebaseAuth = FirebaseAuth.instance;
    if (peerId != "null") {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        // color: Colors.white,
        child: TextButton(
          onPressed: () {
            if (isAdmin || peerId == currentUserId) {

            } else {
              if (KeyboardUtils.isKeyboardShowing()) {
                KeyboardUtils.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                        peerId: peerId,
                        peerAvatar: peerPhotoUrl,
                        peerNickname: peerName,
                        userAvatar: firebaseAuth.currentUser!.photoURL!,
                        schoolName: widget.schoolName,
                      )));
            }
          },
          child: ListTile(
            leading: peerPhotoUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
              child: Image.network(
                peerPhotoUrl,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
                loadingBuilder: (BuildContext ctx, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                          color: Colors.grey,
                          value: loadingProgress.expectedTotalBytes !=
                              null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null),
                    );
                  }
                },
                errorBuilder: (context, object, stackTrace) {
                  return const Icon(Icons.account_circle, size: 50);
                },
              ),
            )
                : const Icon(
              Icons.account_circle,
              size: 50,
            ),
            title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "$peerName - $gradeLevel",
                      style: TextStyle( color: Colors.black,),
                      softWrap: false,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // new
                    ),
                  ),
                ]
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
      // return const SizedBox.shrink();
    }
  }

}

