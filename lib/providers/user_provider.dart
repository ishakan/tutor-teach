// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_firebase_signin/models/chat_user.dart';
// import 'package:google_firebase_signin/providers/auth_provider.dart';
// import 'package:google_firebase_signin/resources/auth_methods.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class UserProvider with ChangeNotifier {
//   final SharedPreferences prefs;
//   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
//   final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
//
//   ChatUser? _user;
//   final AuthProvider _authMethods = AuthProvider(
//     firebaseFirestore: firebaseFirestore,
//     prefs: prefs,
//     googleSignIn: GoogleSignIn(),
//     firebaseAuth: FirebaseAuth.instance);
//   // Future<model.User> getUserDetails() async {
//   //   User currentUser = _auth.currentUser!;
//   //
//   //   DocumentSnapshot documentSnapshot =
//   //   await _firestore.collection('users').doc(currentUser.uid).get();
//   //
//   //   return model.User.fromSnap(documentSnapshot);
//   // }
//   ChatUser get getUser => _user!;
//
//   Future<void> refreshUser() async {
//     ChatUser user = await _authMethods.getUserDetails();
//     _user = user;
//     notifyListeners();
//   }
// }