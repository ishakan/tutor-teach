import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:flutter/services.dart' show rootBundle;

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider(
      {required this.googleSignIn,
      required this.firebaseAuth,
      required this.firebaseFirestore,
      required this.prefs});

  String? getFirebaseUserId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }
  // get user details
  Future<ChatUser> getUserDetails() async {
    User currentUser = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot documentSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    return ChatUser.fromSnap(documentSnapshot);
  }


  Future<bool> isAdminEmail() async {
    final googleUser = await googleSignIn.signIn();

    var collection = FirebaseFirestore.instance.collection('allowed_email');
    var docSnapshot = await collection.doc('allowed_email').get();
    List<dynamic> holder = [];
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      holder = data!['emails'] as List<dynamic>;
    }
    print(holder);
    print(googleUser?.email);
    print("IS ADMIN?");
    return (holder.contains(googleUser?.email));

  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/terms_and_conditions.txt');
  }

  Future<bool> showAlertDialog(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    String content = await loadAsset();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.only(left: 15, right: 15),
        title: Center(child: Text("Terms and Conditions")),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Container(
          // height: 200,
          width: width,
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(content),
                  ]
            )
          ),
        ),
        actions: [
          TextButton(
              child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          TextButton(
              child: Text("ACCEPT", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );
  }

  // Future<bool> showAlertDialog(BuildContext context) async {
  //
  //   // set up the buttons
  //
  //   // set up the AlertDialog
  //   double width = MediaQuery.of(context).size.width;
  //   AlertDialog alert2 = AlertDialog(
  //       contentPadding: EdgeInsets.only(left: 15, right: 15),
  //       title: Center(child: Text("Terms and Conditions")),
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10.0))),
  //       content: Container(
  //         // height: 200,
  //         width: width,
  //         child: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: <Widget>[
  //               // SizedBox(
  //               //   height: 20,
  //               // ),
  //               Text(
  //                 (await loadAsset()),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             TextButton(
  //               child: Text("Cancel"),
  //               onPressed:  () {
  //                 Navigator.pop(context, false);
  //               },
  //             )
  //           ],
  //         ),
  //         TextButton(
  //           child: Text("Accept"),
  //           onPressed:  () {
  //             print(status);
  //             print("STATUS??");
  //             Navigator.pop(context, true);
  //           },
  //         ),
  //       ],
  //   );
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert2;
  //     },
  //   );
  // }

  Future<bool> handleGoogleSignIn(BuildContext context) async {
    // await FirebaseFirestore.instance.collection('allowed_email').get()
    // await FirebaseFirestore.instance.collection('allowed_email').doc(currentUser.uid).get();

    _status = Status.authenticating;
    notifyListeners();

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final email = await googleUser.email;


    // GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null
        // && googleUser.email.contains("ncs.charter.k12.de.us")
    ) {
      // GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      // final AuthCredential credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;

        print("CHECk IF CONTINUE?");
        if (document.isEmpty) {
          bool accepted = await showAlertDialog(context);
          if (accepted) {
            print("IS dialog happening??");
            firebaseFirestore
                .collection(FirestoreConstants.pathUserCollection)
                .doc(firebaseUser.uid)
                .set({
              FirestoreConstants.displayName: firebaseUser.displayName,
              FirestoreConstants.photoUrl: firebaseUser.photoURL,
              FirestoreConstants.id: firebaseUser.uid,
              "createdAt: ": DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString(),
              FirestoreConstants.chattingWith: null,
              FirestoreConstants.email: email
            });

            User? currentUser = firebaseUser;
            await prefs.setString(FirestoreConstants.id, currentUser.uid);
            await prefs.setString(
                FirestoreConstants.displayName, currentUser.displayName ?? "");
            await prefs.setString(
                FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
            await prefs.setString(
                FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
            await prefs.setString(
                FirestoreConstants.email, currentUser.email ?? "");

            var collection = FirebaseFirestore.instance.collection('users').doc(
                currentUser.uid).collection("userMessaged");
            collection
                .doc('test') // <-- Document ID
                .set({'age': 20}) // <-- Your data
                .then((_) => print('Added'))
                .catchError((error) => print('Add failed: $error'));
          } else {
            _status = Status.authenticateCanceled;
            return false;
          }
        } else {
          DocumentSnapshot documentSnapshot = document[0];
          ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(
              FirestoreConstants.displayName, userChat.displayName);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(FirestoreConstants.testing, userChat.testing);
          await prefs.setString(FirestoreConstants.isTutor, userChat.isTutor);
          await prefs.setString(
              FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
          await prefs.setString(
              FirestoreConstants.email, userChat.email);

        }
        _status = Status.authenticated;

        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
