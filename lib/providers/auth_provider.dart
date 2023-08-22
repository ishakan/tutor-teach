import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show FirebaseMessaging;
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/models/pair.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:the_apple_sign_in/scope.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

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

  Future<String> getFirebaseEmail(String schoolName) async {
    print("begnning?");
    print(getFirebaseUserId());
    var collection = await FirebaseFirestore.instance.collection("schools").doc(schoolName).collection('users').doc(getFirebaseUserId()).get();
    String email = "";
    if (collection.exists) {
      Map<String, dynamic>? data = collection.data();
      print(data);
      print("DATAAA");
      email = data!['email'].toString();
    }
    return email;
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    // print(prefs.getString(FirestoreConstants.email));
    print(prefs.getString(FirestoreConstants.id));
    print("VALUES");

    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }
  // get user details
  Future<ChatUser> getUserDetails(String schoolName) async {
    User currentUser = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot documentSnapshot =
    await FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(currentUser.uid).get();

    return ChatUser.fromSnap(documentSnapshot);
  }



  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/terms_and_conditions.txt');
  }

  Future<String> loadAsset2() async {
    return await rootBundle.loadString('assets/apple_terms_and_conditions.txt');
  }

  Future<bool> showAlertDialog(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    String content = await loadAsset();
    String content2 = await loadAsset2();
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
                    Text(content2 + "\n" + content),
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

  Future<Pair> handleGoogleSignIn(String schoolName, String needsToHave, BuildContext context) async {

    Pair notWork = Pair(item1: false, item2: false);
    Pair isAdmin = Pair(item1: true, item2: true);
    Pair isStudent = Pair(item1: true, item2: false);

    _status = Status.authenticating;
    notifyListeners();


    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final email = await googleUser.email;
    // if (!email.contains(needsToHave))


    // GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null
        && email.contains(needsToHave)
    ) {
      // GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      // final AuthCredential credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      // String fcmToken = "";

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print(fcmToken);
      print("FCM TOEKENENENENE");
      // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

      // if (defaultTargetPlatform == TargetPlatform.iOS) {
      //   // Code for iOS platform
      //   _firebaseMessaging.requestPermission();
      //   await _firebaseMessaging.getToken().then((token) {
      //     fcmToken = token.toString();
      //     print(token);
      //
      //   });
      //   print("THIS SI THE TOKENENEN");
      // }

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.allUsersCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;

        print("CHECk IF CONTINUE?");
        if (document.isEmpty) {

          print("Is Empty?");
          bool accepted = await showAlertDialog(context);
          if (accepted) {
            print("IS dialog happening??");
            firebaseFirestore
                .collection(FirestoreConstants.allUsersCollection)
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
              FirestoreConstants.email: email,
              FirestoreConstants.schoolName: schoolName,
              FirestoreConstants.fcmToken: fcmToken,
            });

            firebaseFirestore
                .collection('schools').doc(schoolName)
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
              FirestoreConstants.fcmToken: fcmToken,
              FirestoreConstants.email: email,
              FirestoreConstants.schoolName: schoolName
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
            await prefs.setString(
                FirestoreConstants.schoolName, schoolName ?? "");
            await prefs.setString(
                FirestoreConstants.fcmToken, fcmToken ?? "");

            var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(
                currentUser.uid).collection("userMessaged");
            collection
                .doc('test') // <-- Document ID
                .set({'age': 20}) // <-- Your data
                .then((_) => print('Added'))
                .catchError((error) => print('Add failed: $error'));
          } else {
            _status = Status.authenticateCanceled;
            return notWork;
          }
        } else {
          print(fcmToken);
          print("FCM TOKEN PART 2");

          // profileProvider.updateFirestoreData(
          //     FirestoreConstants.pathUserCollection, id, updateInfo.toJson(), schoolName)
          //     .then((value) async {
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.displayName, displayName);
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.phoneNumber, phoneNumber);
          //   await profileProvider.setPrefs(
          //     FirestoreConstants.photoUrl, photoUrl,);
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.aboutMe,aboutMe );
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.testing,testing );
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.isTutor, isTutor);
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.email, email);
          //   await profileProvider.setPrefs(
          //       FirestoreConstants.schoolName, schoolName);
          //   setState(() {
          //     isLoading = false;
          //   });
          //   Fluttertoast.showToast(msg: 'Update Success');
          // }).catchError((onError) {
          //   Fluttertoast.showToast(msg: onError.toString());
          // });

          firebaseFirestore
              .collection('schools').doc(schoolName)
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .update({
            FirestoreConstants.displayName: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.fcmToken: fcmToken,
          });

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
          await prefs.setString(
              FirestoreConstants.schoolName, userChat.schoolName);
          await prefs.setString(
              FirestoreConstants.fcmToken, "testing if put");

        }
        _status = Status.authenticated;
        notifyListeners();

        LinkedHashMap<String, dynamic>? holdsData;

        var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('allowed_email');
        var docSnapshot = await collection.doc('allowed_email').get();
        List<dynamic> holder = [];
        if (docSnapshot.exists) {
          Map<String, dynamic>? data = docSnapshot.data();
          print(data);
          holder = data!['emails'] as List<dynamic>;
        }
        print(holder);
        print("HOLDERR");
        if (holder.contains(googleUser.email)) {
          return isAdmin;
        } else {
          return isStudent;
        }
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return notWork;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return notWork;
    }
  }

  Future<void> googleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    print("sign out successfull");
  }


  // APPLE SIGN IN

  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
        await firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        print(firebaseUser.email);
        print(firebaseUser.displayName);
        print(firebaseUser.photoURL);
        print(firebaseUser.uid);

        print(scopes.contains(Scope.fullName));
        final fullName = appleIdCredential.fullName;
        if (fullName != null &&
            fullName.givenName != null &&
            fullName.familyName != null) {
          final displayName = '${fullName.givenName} ${fullName.familyName}';
          print("First");
          print(displayName);
          firebaseUser.updateDisplayName(displayName);
          // await firebaseUser.updateDisplayName(displayName);
        }
        final email;
        if (firebaseUser.email == null) {
          email = appleIdCredential.email;
          firebaseUser.updateEmail(email!);
        } else {
          email = firebaseUser.email;
        }

        if (firebaseUser.photoURL == null) {
          firebaseUser.updatePhotoURL("https://lh3.googleusercontent.com/a/AItbvml7SYj9LRT5TH1XOt56azUbQYjqNgUB2JqnWffD=s96-c");
        }

        // print(appleIdCredential.email);
        // print("EMAIL?");
        // firebaseUser.updateEmail(email!);
        // print("EMAIL>???");
        // firebaseUser.updatePhotoURL("https://lh3.googleusercontent.com/a/AItbvml7SYj9LRT5TH1XOt56azUbQYjqNgUB2JqnWffD=s96-c");
        print(firebaseUser.displayName);
        Pair holdData = await appleSignIn(firebaseUser, "NewarkCharterSchool", "");
        print(holdData.item1);
        print(holdData.item2);
        print("HOLDER INFOOO");
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<Pair> appleSignIn(User firebaseUser, String schoolName, String needsToHave) async {
    // if (!email.contains(needsToHave))
    print(firebaseUser.email);
    print(firebaseUser.photoURL);
    print(firebaseUser.displayName);
    print("FIREBASE USER INFO");
    Pair notWork = Pair(item1: false, item2: false);
    Pair isStudent = Pair(item1: true, item2: false);


    // GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (firebaseUser.email!.contains(needsToHave)) {

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.allUsersCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        print(document);
        print("CHECk IF CONTINUE?");
        if (document.isEmpty) {

          print("Is Empty?");
          bool accepted = true;
          if (accepted) {
            print("IS dialog happening??");
            firebaseFirestore
                .collection(FirestoreConstants.allUsersCollection)
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
              FirestoreConstants.email: firebaseUser.email,
              FirestoreConstants.schoolName: schoolName,
            });

            firebaseFirestore
                .collection('schools').doc(schoolName)
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
              FirestoreConstants.email: firebaseUser.email,
              FirestoreConstants.schoolName: schoolName
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
            await prefs.setString(
                FirestoreConstants.schoolName, schoolName ?? "");
            var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(
                currentUser.uid).collection("userMessaged");
            collection
                .doc('test') // <-- Document ID
                .set({'age': 20}) // <-- Your data
                .then((_) => print('Added'))
                .catchError((error) => print('Add failed: $error'));
          }
          else {
            _status = Status.authenticateCanceled;
            return notWork;
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
          await prefs.setString(
              FirestoreConstants.schoolName, userChat.schoolName);
        }
        _status = Status.authenticated;
        notifyListeners();

        LinkedHashMap<String, dynamic>? holdsData;

        var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('allowed_email');
        var docSnapshot = await collection.doc('allowed_email').get();
        List<dynamic> holder = [];
        if (docSnapshot.exists) {
          Map<String, dynamic>? data = docSnapshot.data();
          print(data);
          holder = data!['emails'] as List<dynamic>;
        }
        print(holder);
        print("HOLDERR");
        return isStudent;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return notWork;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return notWork;
    }
  }

}
