import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/pair.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthService extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  AuthService(
      {
        required this.firebaseAuth,
        required this.firebaseFirestore,
        required this.prefs});

  Status _status = Status.uninitialized;

  Status get status => _status;

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
        await _firebaseAuth.signInWithCredential(credential);
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
        final email = appleIdCredential.email;
        print(appleIdCredential.email);
        print("EMAIL?");
        firebaseUser.updateEmail(email!);
        print("EMAIL>???");
        firebaseUser.updatePhotoURL("https://lh3.googleusercontent.com/a/AItbvml7SYj9LRT5TH1XOt56azUbQYjqNgUB2JqnWffD=s96-c");
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