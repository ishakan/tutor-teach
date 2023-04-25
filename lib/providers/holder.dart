// import 'dart:collection';
// import 'dart:html';
// import 'dart:io';
// import 'package:flutter/widgets.dart';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_firebase_signin/models/pair.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_firebase_signin/allConstants/all_constants.dart';
// import 'package:google_firebase_signin/models/chat_user.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// enum Status {
//   uninitialized,
//   authenticated,
//   authenticating,
//   authenticateError,
//   authenticateCanceled,
// }
//
// class AuthProvider extends ChangeNotifier {
//   final GoogleSignIn googleSignIn;
//   final FirebaseAuth firebaseAuth;
//   final FirebaseFirestore firebaseFirestore;
//   final SharedPreferences prefs;
//
//   Status _status = Status.uninitialized;
//
//   Status get status => _status;
//
//   AuthProvider(
//       {required this.googleSignIn,
//         required this.firebaseAuth,
//         required this.firebaseFirestore,
//         required this.prefs});
//
//   String? getFirebaseUserId() {
//     return prefs.getString(FirestoreConstants.id);
//   }
//
//   Future<String> getFirebaseEmail(String schoolName) async {
//     print("begnning?");
//     print(getFirebaseUserId());
//     var collection = await FirebaseFirestore.instance.collection("schools").doc(schoolName).collection('users').doc(getFirebaseUserId()).get();
//     String email = "";
//     if (collection.exists) {
//       Map<String, dynamic>? data = collection.data();
//       print(data);
//       print("DATAAA");
//       email = data!['email'].toString();
//     }
//     return email;
//   }
//
//   Future<bool> isLoggedIn() async {
//     bool isLoggedIn = await googleSignIn.isSignedIn();
//     // print(prefs.getString(FirestoreConstants.email));
//     print(prefs.getString(FirestoreConstants.id));
//     print("VALUES");
//
//     if (isLoggedIn &&
//         prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//   // get user details
//   Future<ChatUser> getUserDetails(String schoolName) async {
//     User currentUser = FirebaseAuth.instance.currentUser!;
//
//     DocumentSnapshot documentSnapshot =
//     await FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(currentUser.uid).get();
//
//     return ChatUser.fromSnap(documentSnapshot);
//   }
//
//   //
//   // Future<bool> isAdminEmail() async {
//   //   final googleUser = await googleSignIn.signIn();
//   //
//   //   var collection = FirebaseFirestore.instance.collection('allowed_email');
//   //   var docSnapshot = await collection.doc('allowed_email').get();
//   //   List<dynamic> holder = [];
//   //   if (docSnapshot.exists) {
//   //     Map<String, dynamic>? data = docSnapshot.data();
//   //     holder = data!['emails'] as List<dynamic>;
//   //   }
//   //   print(holder);
//   //   print(googleUser?.email);
//   //   print("IS ADMIN?");
//   //
//   //   LinkedHashMap<String, dynamic>? holdsData;
//   //
//   //   String id = googleUser!.id;
//   //   print(id);
//   //   DocumentReference documentReference = FirebaseFirestore.instance.collection('allUsers').doc(id);
//   //   await documentReference.get().then((snapshot) {
//   //
//   //     print(snapshot.data());
//   //     if (snapshot.data() != null) {
//   //       holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
//   //     }
//   //   });
//   //   print("See what happens");
//   //
//   //   return (holder.contains(googleUser?.email));
//   // }
//
//   Future<String> loadAsset() async {
//     return await rootBundle.loadString('assets/terms_and_conditions.txt');
//   }
//
//   Future<bool> showAlertDialog(BuildContext context) async {
//     double width = MediaQuery.of(context).size.width;
//     String content = await loadAsset();
//     return await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         contentPadding: EdgeInsets.only(left: 15, right: 15),
//         title: Center(child: Text("Terms and Conditions")),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10.0))),
//         content: Container(
//           // height: 200,
//           width: width,
//           child: SingleChildScrollView(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     Text(content),
//                   ]
//               )
//           ),
//         ),
//         actions: [
//           TextButton(
//               child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
//               onPressed: () {
//                 Navigator.pop(context, false);
//               }),
//           TextButton(
//               child: Text("ACCEPT", style: TextStyle(color: Colors.blue)),
//               onPressed: () {
//                 Navigator.pop(context, true);
//               })
//         ],
//       ),
//     );
//   }
//
//   Future<Pair> handleGoogleSignIn(String schoolName, String needsToHave, BuildContext context) async {
//     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//     Pair notWork = Pair(item1: false, item2: false);
//     Pair isAdmin = Pair(item1: true, item2: true);
//     Pair isStudent = Pair(item1: true, item2: false);
//
//     _status = Status.authenticating;
//     notifyListeners();
//
//     final googleUser = await googleSignIn.signIn();
//     final googleAuth = await googleUser!.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     final email = await googleUser.email;
//     // if (!email.contains(needsToHave))
//
//
//     // GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//     if (googleUser != null
//         && email.contains(needsToHave)
//     ) {
//       // GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
//       // final AuthCredential credential = GoogleAuthProvider.credential(
//       //   accessToken: googleAuth.accessToken,
//       //   idToken: googleAuth.idToken,
//       // );
//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         // Code for iOS platform
//         _firebaseMessaging.requestPermission();
//         await _firebaseMessaging.getToken().then((token) {
//           print(token);
//         });
//         print("THIS SI THE TOKENENEN");
//       } else if (defaultTargetPlatform == TargetPlatform.android) {
//         // Code for Android platform
//       }
//
//       String fcmToken = "";
//       FirebaseMessaging.instance.getToken().then((value) {
//         fcmToken = value ?? "";
//       });
//
//       print(fcmToken);
//       print("FCZMTZOKEN");
//
//       User? firebaseUser =
//           (await firebaseAuth.signInWithCredential(credential)).user;
//
//       if (firebaseUser != null) {
//         final QuerySnapshot result = await firebaseFirestore
//             .collection(FirestoreConstants.allUsersCollection)
//             .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
//             .get();
//         final List<DocumentSnapshot> document = result.docs;
//
//         print("CHECk IF CONTINUE?");
//         if (document.isEmpty) {
//
//           print("Is Empty?");
//           bool accepted = await showAlertDialog(context);
//           if (accepted) {
//             print("IS dialog happening??");
//             firebaseFirestore
//                 .collection(FirestoreConstants.allUsersCollection)
//                 .doc(firebaseUser.uid)
//                 .set({
//               FirestoreConstants.displayName: firebaseUser.displayName,
//               FirestoreConstants.photoUrl: firebaseUser.photoURL,
//               FirestoreConstants.id: firebaseUser.uid,
//               "createdAt: ": DateTime
//                   .now()
//                   .millisecondsSinceEpoch
//                   .toString(),
//               FirestoreConstants.chattingWith: null,
//               FirestoreConstants.email: email,
//               FirestoreConstants.schoolName: schoolName,
//               FirestoreConstants.fcmToken: fcmToken,
//             });
//
//             firebaseFirestore
//                 .collection('schools').doc(schoolName)
//                 .collection(FirestoreConstants.pathUserCollection)
//                 .doc(firebaseUser.uid)
//                 .set({
//               FirestoreConstants.displayName: firebaseUser.displayName,
//               FirestoreConstants.photoUrl: firebaseUser.photoURL,
//               FirestoreConstants.id: firebaseUser.uid,
//               "createdAt: ": DateTime
//                   .now()
//                   .millisecondsSinceEpoch
//                   .toString(),
//               FirestoreConstants.chattingWith: null,
//               FirestoreConstants.fcmToken: fcmToken,
//               FirestoreConstants.email: email,
//               FirestoreConstants.schoolName: schoolName
//             });
//
//             User? currentUser = firebaseUser;
//             await prefs.setString(FirestoreConstants.id, currentUser.uid);
//             await prefs.setString(
//                 FirestoreConstants.displayName, currentUser.displayName ?? "");
//             await prefs.setString(
//                 FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
//             await prefs.setString(
//                 FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
//             await prefs.setString(
//                 FirestoreConstants.email, currentUser.email ?? "");
//             await prefs.setString(
//                 FirestoreConstants.schoolName, schoolName ?? "");
//             await prefs.setString(
//                 FirestoreConstants.fcmToken, fcmToken ?? "");
//
//             var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(
//                 currentUser.uid).collection("userMessaged");
//             collection
//                 .doc('test') // <-- Document ID
//                 .set({'age': 20}) // <-- Your data
//                 .then((_) => print('Added'))
//                 .catchError((error) => print('Add failed: $error'));
//           } else {
//             _status = Status.authenticateCanceled;
//             return notWork;
//           }
//         } else {
//           DocumentSnapshot documentSnapshot = document[0];
//           ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
//           await prefs.setString(FirestoreConstants.id, userChat.id);
//           await prefs.setString(
//               FirestoreConstants.displayName, userChat.displayName);
//           await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
//           await prefs.setString(FirestoreConstants.testing, userChat.testing);
//           await prefs.setString(FirestoreConstants.isTutor, userChat.isTutor);
//           await prefs.setString(
//               FirestoreConstants.photoUrl, userChat.photoUrl);
//           await prefs.setString(
//               FirestoreConstants.phoneNumber, userChat.phoneNumber);
//           await prefs.setString(
//               FirestoreConstants.email, userChat.email);
//           await prefs.setString(
//               FirestoreConstants.schoolName, userChat.schoolName);
//           await prefs.setString(
//               FirestoreConstants.fcmToken, userChat.fcmToken);
//
//         }
//         _status = Status.authenticated;
//         notifyListeners();
//
//         LinkedHashMap<String, dynamic>? holdsData;
//
//         var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('allowed_email');
//         var docSnapshot = await collection.doc('allowed_email').get();
//         List<dynamic> holder = [];
//         if (docSnapshot.exists) {
//           Map<String, dynamic>? data = docSnapshot.data();
//           print(data);
//           holder = data!['emails'] as List<dynamic>;
//         }
//         print(holder);
//         print("HOLDERR");
//         if (holder.contains(googleUser.email)) {
//           return isAdmin;
//         } else {
//           return isStudent;
//         }
//       } else {
//         _status = Status.authenticateError;
//         notifyListeners();
//         return notWork;
//       }
//     } else {
//       _status = Status.authenticateCanceled;
//       notifyListeners();
//       return notWork;
//     }
//   }
//
//   Future<void> googleSignOut() async {
//     _status = Status.uninitialized;
//     await firebaseAuth.signOut();
//     await googleSignIn.disconnect();
//     await googleSignIn.signOut();
//   }
// }
