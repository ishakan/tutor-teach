// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// import 'package:google_firebase_signin/allConstants/all_constants.dart';
// import 'package:google_firebase_signin/allWidgets/loading_view.dart';
// import 'package:google_firebase_signin/models/chat_user.dart';
// import 'package:google_firebase_signin/providers/auth_provider.dart';
// import 'package:google_firebase_signin/providers/home_provider.dart';
// import 'package:google_firebase_signin/screens/chat_page.dart';
// import 'package:google_firebase_signin/screens/login_page.dart';
// import 'package:google_firebase_signin/screens/profile_page.dart';
// import 'package:google_firebase_signin/utilities/debouncer.dart';
// import 'package:google_firebase_signin/utilities/keyboard_utils.dart';
//
// class TutorPage extends StatefulWidget {
//   final String schoolName;
//   const TutorPage({
//     Key? key,
//     required this.schoolName,
//   }) : super(key: key);
//   // const TutorPage({Key? key}) : super(key: key);
//
//   @override
//   State<TutorPage> createState() => _TutorPageState();
// }
//
// class _TutorPageState extends State<TutorPage> {
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   final ScrollController scrollController = ScrollController();
//
//   int _limit = 100;
//   final int _limitIncrement = 20;
//   String _textSearch = "";
//   bool isLoading = false;
//   String subjects = "subjects";
//
//   late AuthProvider authProvider;
//   late String currentUserId;
//   late HomeProvider homeProvider;
//
//   Debouncer searchDebouncer = Debouncer(milliseconds: 300);
//   StreamController<bool> buttonClearController = StreamController<bool>();
//   TextEditingController searchTextEditingController = TextEditingController();
//
//   Future<void> googleSignOut() async {
//     authProvider.googleSignOut();
//     Navigator.push(
//         context, MaterialPageRoute(builder: (context) => const LoginPage()));
//   }
//
//   Future<bool> onBackPress() {
//     openDialog();
//     return Future.value(false);
//   }
//
//   Future<void> openDialog() async {
//     switch (await showDialog(
//         context: context,
//         builder: (BuildContext ctx) {
//           return SimpleDialog(
//             backgroundColor: AppColors.burgundy,
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   'Exit Application',
//                   style: TextStyle(color: AppColors.white),
//                 ),
//                 Icon(
//                   Icons.exit_to_app,
//                   size: 30,
//                   color: Colors.white,
//                 ),
//               ],
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(Sizes.dimen_10),
//             ),
//             children: [
//               vertical10,
//               const Text(
//                 'Are you sure?',
//                 textAlign: TextAlign.center,
//                 style:
//                 TextStyle(color: AppColors.white, fontSize: Sizes.dimen_16),
//               ),
//               vertical15,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   SimpleDialogOption(
//                     onPressed: () {
//                       Navigator.pop(context, 0);
//                     },
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(color: AppColors.white),
//                     ),
//                   ),
//                   SimpleDialogOption(
//                     onPressed: () {
//                       Navigator.pop(context, 1);
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(Sizes.dimen_8),
//                       ),
//                       padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
//                       child: const Text(
//                         'Yes',
//                         style: TextStyle(color: AppColors.spaceCadet),
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             ],
//           );
//         })) {
//       case 0:
//         break;
//       case 1:
//         exit(0);
//     }
//   }
//
//   void scrollListener() {
//     if (scrollController.offset >= scrollController.position.maxScrollExtent &&
//         !scrollController.position.outOfRange) {
//       setState(() {
//         _limit += _limitIncrement;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     buttonClearController.close();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     authProvider = context.read<AuthProvider>();
//     homeProvider = context.read<HomeProvider>();
//     if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
//       currentUserId = authProvider.getFirebaseUserId()!;
//     } else {
//       Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//               (Route<dynamic> route) => false);
//     }
//
//     scrollController.addListener(scrollListener);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           centerTitle: true,
//             leading: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back)), // you can put Icon as well, it accepts any widget.
//             title: const Text('All Tutors'),
//         ),
//         body: WillPopScope(
//           onWillPop: onBackPress,
//           child: Stack(
//             children: [
//               SingleChildScrollView(
//                 child: Column(
//                     children: [
//                 // buildSearchBar(),
//                       StreamBuilder<QuerySnapshot>(
//                         stream: homeProvider.getFirestoreData(
//                             FirestoreConstants.pathUserCollection,
//                             _limit,
//                             _textSearch),
//                         builder: (BuildContext context,
//                             AsyncSnapshot<QuerySnapshot> snapshot) {
//                           if (snapshot.hasData) {
//                             if ((snapshot.data?.docs.length ?? 0) > 0) {
//                               return ListView.separated(
//                                 shrinkWrap: true,
//                                 itemCount: snapshot.data!.docs.length,
//                                 itemBuilder: (context, index) => buildItem2(
//                                     context, snapshot.data?.docs[index]),
//                                 controller: scrollController,
//                                 separatorBuilder:
//                                     (BuildContext context, int index) =>
//                                   const Divider(),
//                               );
//                             } else {
//                               return const Center(
//                                 child: Text('No current tutors...'),
//                               );
//                             }
//                           } else {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//               ),
//               Positioned(
//                 child:
//                 isLoading ? const LoadingView() : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ));
//   }
//
//
//   Widget buildTitle(String input, Color subColor) {
//     return Container(
//       margin: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10), // <= No more error here :)
//         color: subColor,
//       ),
//       height: 25,
//       width: MediaQuery.of(context).size.width,
//       child: Text(input,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             // fontStyle: FontStyle.italic,
//             letterSpacing: 3,
//             wordSpacing: 20,
//             // backgroundColor: Colors.black,
//             // shadows: [
//             //   Shadow(color: Colors.blueAccent, offset: Offset(2,1), blurRadius:10)
//             // ]
//         ),
//       ),
//     );
//   }
//
//
//   Widget buildSearchBar() {
//     return Container(
//       margin: const EdgeInsets.all(Sizes.dimen_10),
//       height: Sizes.dimen_50,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(Sizes.dimen_30),
//         color: AppColors.spaceLight,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(
//             width: Sizes.dimen_10,
//           ),
//           const Icon(
//             Icons.person_search,
//             color: AppColors.white,
//             size: Sizes.dimen_24,
//           ),
//           const SizedBox(
//             width: 5,
//           ),
//           Expanded(
//             child: TextFormField(
//               textInputAction: TextInputAction.search,
//               controller: searchTextEditingController,
//               onChanged: (value) {
//                 if (value.isNotEmpty) {
//                   buttonClearController.add(true);
//                   setState(() {
//                     _textSearch = value;
//                   });
//                 } else {
//                   buttonClearController.add(false);
//                   setState(() {
//                     _textSearch = "";
//                   });
//                 }
//               },
//               decoration: const InputDecoration.collapsed(
//                 hintText: 'Biology Tutors',
//                 hintStyle: TextStyle(color: AppColors.white),
//               ),
//             ),
//           ),
//           StreamBuilder(
//               stream: buttonClearController.stream,
//               builder: (context, snapshot) {
//                 return snapshot.data == true
//                     ? GestureDetector(
//                   onTap: () {
//                     searchTextEditingController.clear();
//                     buttonClearController.add(false);
//                     setState(() {
//                       _textSearch = '';
//                     });
//                   },
//                   child: const Icon(
//                     Icons.clear_rounded,
//                     color: AppColors.greyColor,
//                     size: 20,
//                   ),
//                 )
//                     : const SizedBox.shrink();
//               })
//         ],
//       ),
//     );
//   }
//
//   Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot, String subject) {
//     final firebaseAuth = FirebaseAuth.instance;
//     if (documentSnapshot != null) {
//       ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
//       //userChat.id == currentUserId ||
//       bool checkifTutor = (userChat.isTutor == "yes");
//
//       if (!checkifTutor) {
//         // return const SizedBox.shrink();
//         return Container(
//           height: 0,
//           width: 0,
//         );
//       } else {
//         return Container(
//           color: Colors.white,
//             child: TextButton(
//           onPressed: () {
//             if (KeyboardUtils.isKeyboardShowing()) {
//               KeyboardUtils.closeKeyboard(context);
//             }
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => ChatPage(
//                       peerId: userChat.id,
//                       peerAvatar: userChat.photoUrl,
//                       peerNickname: userChat.displayName,
//                       userAvatar: firebaseAuth.currentUser!.photoURL!,
//                       schoolName: widget.schoolName,
//                     )));
//           },
//           child: ListTile(
//             leading: userChat.photoUrl.isNotEmpty
//                 ? ClipRRect(
//               borderRadius: BorderRadius.circular(Sizes.dimen_30),
//               child: Image.network(
//                 userChat.photoUrl,
//                 fit: BoxFit.cover,
//                 width: 50,
//                 height: 50,
//                 loadingBuilder: (BuildContext ctx, Widget child,
//                     ImageChunkEvent? loadingProgress) {
//                   if (loadingProgress == null) {
//                     return child;
//                   } else {
//                     return SizedBox(
//                       width: 50,
//                       height: 50,
//                       child: CircularProgressIndicator(
//                           color: Colors.grey,
//                           value: loadingProgress.expectedTotalBytes !=
//                               null
//                               ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                               : null),
//                     );
//                   }
//                 },
//                 errorBuilder: (context, object, stackTrace) {
//                   return const Icon(Icons.account_circle, size: 50);
//                 },
//               ),
//             )
//                 : const Icon(
//               Icons.account_circle,
//               size: 50,
//             ),
//             title: Row(
//               children: [
//                 Text(
//                   userChat.displayName,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     " - ${userChat.aboutMe}",
//                     style: const TextStyle(color: Colors.black),
//                   ),
//                 ),
//               ]
//             ),
//           ),
//         ),
//         );
//       }
//     } else {
//       return Container(
//         height: 0,
//         width: 0,
//       );
//       // return const SizedBox.shrink();
//     }
//   }
//
//
//   Widget buildItem2(BuildContext context, DocumentSnapshot? documentSnapshot) {
//     final firebaseAuth = FirebaseAuth.instance;
//     if (documentSnapshot != null) {
//       ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
//       if (userChat.id == currentUserId) {
//         return const SizedBox(width: 0, height: 0,);
//       } else {
//         String groupChatId = "";
//         if (currentUserId.compareTo(userChat.id) > 0) {
//           groupChatId = '$currentUserId - ${userChat.id}';
//         } else {
//           groupChatId = '${userChat.id} - $currentUserId';
//         }
//
//           return TextButton(
//             onPressed: () {
//               if (KeyboardUtils.isKeyboardShowing()) {
//                 KeyboardUtils.closeKeyboard(context);
//               }
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           ChatPage(
//                             peerId: userChat.id,
//                             peerAvatar: userChat.photoUrl,
//                             peerNickname: userChat.displayName,
//                             userAvatar: firebaseAuth.currentUser!.photoURL!,
//                             schoolName: widget.schoolName,
//                           )));
//             },
//             child: ListTile(
//               leading: userChat.photoUrl.isNotEmpty
//                   ? ClipRRect(
//                 borderRadius: BorderRadius.circular(Sizes.dimen_30),
//                 child: Image.network(
//                   userChat.photoUrl,
//                   fit: BoxFit.cover,
//                   width: 50,
//                   height: 50,
//                   loadingBuilder: (BuildContext ctx, Widget child,
//                       ImageChunkEvent? loadingProgress) {
//                     if (loadingProgress == null) {
//                       return child;
//                     } else {
//                       return SizedBox(
//                         width: 50,
//                         height: 50,
//                         child: CircularProgressIndicator(
//                             color: Colors.grey,
//                             value: loadingProgress.expectedTotalBytes !=
//                                 null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                 loadingProgress.expectedTotalBytes!
//                                 : null),
//                       );
//                     }
//                   },
//                   errorBuilder: (context, object, stackTrace) {
//                     return const Icon(Icons.account_circle, size: 50);
//                   },
//                 ),
//               )
//                   : const Icon(
//                 Icons.account_circle,
//                 size: 50,
//               ),
//               title: Text(
//                 userChat.displayName,
//                 style: const TextStyle(color: Colors.black),
//               ),
//             ),
//           );
//       }
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
// }
//
// // }
//
