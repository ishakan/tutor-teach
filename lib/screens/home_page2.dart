import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allWidgets/post_card.dart';
import 'package:google_firebase_signin/allWidgets/user_card.dart';
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

import 'chips.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  int x = 17;

  int _limit = 20;
  String holdContent = "";
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  bool checkLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  int countNumMessaged = 0;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<bool> onBackPress() {

    if(x==_limit){
      x=15;

    }
//{567}
    openDialog();
    return Future.value(false);
  }

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

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }

    scrollController.addListener(scrollListener);
    forAsync();
  }

  void forAsync() async {
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('userMessaged');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    countNumMessaged = querySnapshot.size - 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const webScreenSize = 600;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () => googleSignOut(),
              icon: const Icon(Icons.logout)), // you can put Icon as well, it accepts any widget.
          title: const Text('TutorTeach'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GoToTutorsPage()));
                },
                icon: const Icon(Icons.supervisor_account_rounded)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()));
                },
                icon: const Icon(Icons.person)),
          ]),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: [
            Column(
              children: [
                buildSearchBar(),
                // FutureBuilder<QuerySnapshot<Map<String, dynamic>>> (
                //   builder: (_, snapshot) {
                //     if (snapshot.hasData) {
                //       return ListView.builder(
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemBuilder: (_, index) {
                //           return ListTile(
                //           );
                //         },
                //       );
                //     } else {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       )
                //     }
                //   },
                //   future: getDataViaFuture(),
                // )
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
                          child: Text(display),
                        );
                      }
                    },
                  ),
                ),
                // Expanded(
                // child: StreamBuilder<QuerySnapshot>(
                //   stream: homeProvider.getFirestoreData(
                //       FirestoreConstants.pathUserCollection,
                //       _limit,
                //       _textSearch),
                //   builder: (BuildContext context,
                //       AsyncSnapshot<QuerySnapshot> snapshot) {
                //     if (snapshot.hasData) {
                //       if ((snapshot.data?.docs.length ?? 0) > 0) {
                //         return ListView.separated(
                //           shrinkWrap: true,
                //           itemCount: snapshot.data!.docs.length,
                //           itemBuilder: (context, index) => buildItem(
                //               context, snapshot.data?.docs[index]),
                //           controller: scrollController,
                //           separatorBuilder:
                //               (BuildContext context, int index) =>
                //             const Divider(),
                //         );
                //       } else {
                //         return const Center(
                //           child: Text('No current tutors...'),
                //         );
                //       }
                //     } else {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     }
                //   },
                // ),
                // ),
              ],
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
    return FirebaseFirestore.instance.collection("users").doc(currentUserId).collection('userMessaged').orderBy("timestamp").get();
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: Sizes.dimen_50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_30),
        color: AppColors.spaceLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: Sizes.dimen_10,
          ),
          const Icon(
            Icons.person_search,
            color: AppColors.white,
            size: Sizes.dimen_24,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          StreamBuilder(
              stream: buttonClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                  onTap: () {
                    searchTextEditingController.clear();
                    buttonClearController.add(false);
                    setState(() {
                      _textSearch = '';
                    });
                  },
                  child: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.greyColor,
                    size: 20,
                  ),
                )
                    : const SizedBox.shrink();
              })
        ],
      ),
    );
  }

  Future<void> getDataForSubject(String id) async {
    String firstId = "";
    final QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('messages').doc(id).collection(id).get();
    for (int i = 0; i < 1; i++) {
      firstId = querySnapshot.docs[i].id.toString();
    }

    late LinkedHashMap<String, dynamic> holdsData;

    DocumentReference documentReference = FirebaseFirestore.instance.collection('messages').doc(id).collection(id).doc(firstId);
    List values = [];
    await documentReference.get().then((snapshot) {
      holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
      holdContent = holdsData["content"];
      print(holdContent);
      print("holdContent-FIRST");
    });
    checkLoading = true;
  }

  void runFunction(String id) async {
    await getDataForSubject(id);
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.id == currentUserId) {
        return const SizedBox(width: 0, height: 0,);
      } else {
          return TextButton(
            onPressed: () {
              if (KeyboardUtils.isKeyboardShowing()) {
                KeyboardUtils.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(
                            peerId: userChat.id,
                            peerAvatar: userChat.photoUrl,
                            peerNickname: userChat.displayName,
                            userAvatar: firebaseAuth.currentUser!.photoURL!,
                          )));
            },
            child: ListTile(
              leading: userChat.photoUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.dimen_30),
                child: Image.network(
                  userChat.photoUrl,
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
              title: Text(
                userChat.displayName,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}

// get admin working
// fix subjects
// get posts working
// fix search bar
// fix display in home page
// fix UI