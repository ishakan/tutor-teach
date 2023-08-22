import 'dart:collection';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/models/report.dart';
import 'package:google_firebase_signin/models/report_user.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/resources/storage_methods.dart';
import 'package:google_firebase_signin/screens/home_page2.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:mailer/smtp_server.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:mailer/mailer.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /**
   * uploads service hour opportunity post onto Firebase Database
   * @param description - description of post
   * @param file - image of post
   * @param uid - Id of user making the post
   * @param title - title of the post
   */

  Future<String> uploadPost(String description, Uint8List file, String uid, String title,
      String username, String profImage, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
      await StorageMethods().uploadImageToStorage('posts', file, true);
      int id = DateTime.now().millisecondsSinceEpoch;
      id *= -1;
      String postId = id.toString();
      Post post = Post(
        post_description: description,
        post_title: title,
        idFrom: uid,
        displayName: username,
        timestamp: formattedDate,
        post_image: photoUrl,
        photoUrl: profImage,
        likes: [],
        bookMarked: [],
        postId: id,
      );
      _SchooldocRef.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  void showSnackBar(String text, BuildContext context) {
    final snackBar = SnackBar(
        content: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.green,
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }


  /**
   * uploads service hour opportunity post onto Firebase Database
   * @param description - description of post
   * @param uid - Id of user making the post
   * @param title - title of the post
   */

  Future<String> uploadPost_withoutPhoto(String description, String uid, String title,
      String username, String profImage, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      int id = DateTime.now().millisecondsSinceEpoch;
      id *= -1;
      String postId = id.toString();
      Post post = Post(
        post_description: description,
        post_title: title,
        idFrom: uid,
        displayName: username,
        timestamp: formattedDate,
        post_image: "None",
        photoUrl: profImage,
        likes: [],
        bookMarked: [],
        postId: id,
      );
      _SchooldocRef.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  /**
   * checker to see if post has been bookmarked of saved by user
   * @param postId - Id of post
   * @param uid - Id of user
   * @param schoolName - name of school that the user has registered under
   */

  Future<bool> tellIfContained(String uid, String postId, String schoolName) async {
    DocumentReference _SchooldocRef =
    FirebaseFirestore.instance.collection('schools').doc(schoolName);

    String res = "Some error occurred";
    late LinkedHashMap<String, dynamic> holdsData;

    DocumentReference documentReference = _SchooldocRef.collection('users').doc(uid);
    List bookMarks = [];
    await documentReference.get().then((snapshot) {
      holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
      bookMarks = holdsData["bookMarkedPosts"];
    });
    print(bookMarks);
    print(uid);
    print(postId);
    print(bookMarks.contains(postId));
    print("TELL IF CONTAINED");
    return bookMarks.contains(postId);
  }


  /**
   * checker to see if post has been liked by user
   * @param postId - Id of post
   * @param list - lists of liked posts by user
   * @param schoolName - name of school that the user has registered under
   */

  Future<String> likePost(String postId, String uid, List likes, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);

    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _SchooldocRef.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _SchooldocRef.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  /**
   * checker to see if post has been bookmarked by user
   * @param postId - Id of post
   * @param bookMarked - lists of posts bookMarked by user
   * @param schoolName - name of school that the user has registered under
   */

  Future<String> bookMarkPost(String postId, String uid, List bookMarked, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);

    String res = "Some error occurred";
    try {
      if (bookMarked.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _SchooldocRef.collection('posts').doc(postId).update({
          'bookMarked': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _SchooldocRef.collection('posts').doc(postId).update({
          'bookMarked': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  /**
   * updates course for users profile
   * @param uid - Id of user
   * @param state - whether user has signed up to tutor that course
   * @param schoolName - name of school that the user has registered under
   */

  Future<String> updateSubject(String subject, String uid, bool state, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);
    String res = "Some error occurred";
    try {
      if (state == false) {
        // if the likes list contains the user uid, we need to remove it
        _SchooldocRef.collection('subjects').doc(subject).update({
          subject: FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _SchooldocRef.collection('subjects').doc(subject).update({
          subject: FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  /**
   * deletes post
   * @param postId - Id of post
   * @param schoolName - name of school that the user has registered under
   */

  Future<String> deleteBadMessage(String postId, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);
    String res = "Some error occurred";

    try {
      await _SchooldocRef.collection('bad_messages').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId, String schoolName) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);
    String res = "Some error occurred";

    try {
      await _SchooldocRef.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> deleteCollection(String uid, String schoolName) async {
    final collectionRef = _firestore.collection('schools').doc(schoolName).collection('users').doc(uid).collection('userMessaged');
    final querySnapshot2 = await collectionRef.get();
    final batchSize = querySnapshot2.size;

    QuerySnapshot querySnapshot;
    do {
      querySnapshot = await collectionRef.limit(batchSize).get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } while (querySnapshot.size == batchSize);
  }


  Future<void> deleteCollectionforMessages(String docName, String schoolName) async {
    final collectionRef = _firestore.collection('schools').doc(schoolName).collection('messages').doc(docName).collection(docName);
    final querySnapshot2 = await collectionRef.get();
    final batchSize = querySnapshot2.size;

    QuerySnapshot querySnapshot;
    do {
      querySnapshot = await collectionRef.limit(batchSize).get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } while (querySnapshot.size == batchSize);
  }


  Future<String> deleteAccount(String schoolName, String uid, AuthProvider authProvider) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await authProvider.googleSignOut();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    DocumentReference _SchooldocRef =
      _firestore.collection('schools').doc(schoolName);
      String res = "Some error occurred";
      try {
        print("Begin");
        // deleting from subjects
        QuerySnapshot<Map<String, dynamic>> snapshot = await _SchooldocRef.collection('subjects').get();
        print(snapshot);
        print("snapshot");

        for (int i = 0; i < snapshot.docs.length; i++) {
          String subject = snapshot.docs[i].id.toString();
          _SchooldocRef.collection('subjects').doc(subject).update({
            subject: FieldValue.arrayRemove([uid])
           });
        }

        // fix this

        // deleting messages
        // print("before");
        // AsyncSnapshot<QuerySnapshot> snapshotMessagess = (await _SchooldocRef.collection('messages').get()) as AsyncSnapshot<QuerySnapshot<Object?>>;
        // print("after");
        // //
        //
        // print(snapshotMessagess.data);
        // print(snapshotMessages);
        // print("snapshotMessages");

        // deleting messages
        QuerySnapshot<Map<String, dynamic>> snapshotMessages = await _SchooldocRef.collection('messages').get();

        print(snapshotMessages);
        print("snapshotMessages");
        print(snapshotMessages.docs);


        for (int i = 0; i < snapshotMessages.docs.length; i++) {
          String messagesBetween = snapshotMessages.docs[i].id.toString();
          print(messagesBetween);
          print("messagesBetween");

          if (messagesBetween.contains(uid)) {
            await deleteCollectionforMessages(messagesBetween, schoolName);
            await _SchooldocRef.collection('messages').doc(messagesBetween).delete();
            print('deleted');
            print(uid);
          }
        }


        QuerySnapshot<Map<String, dynamic>> snapshot_posts = await _SchooldocRef.collection('posts').get();

        print(snapshot_posts.docs);
        print("snpashot_posts");
        for (int i = 0; i < snapshot_posts.docs.length; i++) {
          String messagesBetween = snapshot_posts.docs[i].id.toString();
          Map<String, dynamic> allData = snapshot_posts.docs[i].data();
          _SchooldocRef.collection('posts').doc(messagesBetween).update({
            "likes" : FieldValue.arrayRemove([uid])
          });
          if (allData["idFrom"] == uid) {
            final docRef = _SchooldocRef.collection('posts').doc(messagesBetween);
            docRef.delete();
          }
        }

        // deleting user information & deleting from view in homepage
        QuerySnapshot<Map<String, dynamic>> snapshot_user = await _SchooldocRef.collection('users').get();

        // await _SchooldocRef.c
        await deleteCollection(uid, schoolName);

        await _SchooldocRef.collection('users').doc(uid).delete();

        for (int i = 0; i < snapshot_user.docs.length; i++) {
          String personal_id = snapshot_user.docs[i].id.toString();
          await _SchooldocRef.collection('users').doc(personal_id).collection('userMessaged').doc(uid).delete();
        }


        await _firestore.collection('allUsers').doc(uid).delete();

        // delete user final
        final FirebaseAuth _auth = FirebaseAuth.instance;

        final User user = _auth.currentUser!;
        await user.delete();

        print("finished?");

        res = 'success';
      } catch (err) {
        res = err.toString();
      }
      return res;

  }



  Future<String> reportPost(String postId, String schoolName, String posterId, String uid) async {
    //
    // Future<String> uploadPost_withoutPhoto(String description, String uid, String title,
    //     String username, String profImage, String schoolName) async {
      DocumentReference _SchooldocRef =
      _firestore.collection('schools').doc(schoolName);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
      String res = "Some error occurred";
      try {
        int id = DateTime.now().millisecondsSinceEpoch;
        id *= -1;
        String postId = id.toString();
        ReportPost report = ReportPost(
          poster_id: posterId,
          timestamp: formattedDate,
          post_id: postId,
          id_of_peron_who_reported_post: uid,
        );
        _SchooldocRef.collection('reportedposts').doc(postId).set(report.toJson());
        res = "success";
      } catch (err) {
        res = err.toString();
      }
      return res;
  }


  Future<String> reportUser(String schoolName, String reportedId, String uid) async {
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);
    print("reporting user???");
    print(schoolName);
    print(reportedId);
    print(uid);
    print("DOne sandwhich");
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    String res = "Some error occurred";
    try {
      int id = DateTime.now().millisecondsSinceEpoch;
      id *= -1;
      String postId = id.toString();
      ReportUser report = ReportUser(
        user_id: reportedId,
        timestamp: formattedDate,
        id_of_peron_who_reported_user: uid,
      );
      _SchooldocRef.collection('reportedusers').doc(postId).set(report.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}