import 'dart:collection';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/resources/storage_methods.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid, String title,
      String username, String profImage) async {
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
      _firestore.collection('posts').doc(postId).set(post.toJson());

      // List<String> allEmails = [];
      //
      // QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').get();
      //
      // for (int i = 0; i < snapshot.docs.length; i++) {
      //   Map<String, dynamic> allData = snapshot.docs[i].data();
      //   allEmails.add(allData["email"]);
      // }
      //
      // print(allEmails);
      // print("ALL EMAILs");
      // final Email send_email = Email(
      //   body: 'body of email',
      //   subject: title,
      //   recipients: ['example1@ex.com'],
      //   attachmentPaths: ['/path/to/email_attachment.zip'],
      //   isHTML: false,
      // );
      //
      // await FlutterEmailSender.send(send_email);

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPost_withoutPhoto(String description, String uid, String title,
      String username, String profImage) async {
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
      _firestore.collection('posts').doc(postId).set(post.toJson());


      // List<String> allEmails = [];
      //
      // QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').get();
      // print("Before");
      // for (int i = 0; i < snapshot.docs.length; i++) {
      //   Map<String, dynamic> allData = snapshot.docs[i].data();
      //   String email = allData["email"] ?? "";
      //   if (email != "") {
      //     allEmails.add(email);
      //   }
      // }
      //
      // for (int i =0; i < allEmails.length; i++) {
      //   final Email send_email = Email(
      //     body: description,
      //     subject: "New Service Opportunity - " + title,
      //     recipients: [allEmails[i]],
      //     // attachmentPaths: ['/path/to/email_attachment.zip'],
      //     isHTML: false,
      //   );
      //   await FlutterEmailSender.send(send_email);
      // }
      // print(allEmails);
      // print("ALL EMAILs");
      //


      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<bool> tellIfContained(String uid, String postId) async {
    String res = "Some error occurred";
    late LinkedHashMap<String, dynamic> holdsData;

    DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(uid);
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

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  Future<String> bookMarkPost(String postId, String uid, List bookMarked) async {
    String res = "Some error occurred";
    try {
      if (bookMarked.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'bookMarked': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'bookMarked': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> updateSubject(String subject, String uid, bool state) async {
    String res = "Some error occurred";
    try {
      if (state == false) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('subjects').doc(subject).update({
          subject: FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('subjects').doc(subject).update({
          subject: FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Future<String> bookMarkPost(String postId, String uid) async {
  //   String res = "Some error occurred";
  //   late LinkedHashMap<String, dynamic> holdsData;
  //
  //   DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(uid);
  //   List bookMarks = [];
  //   await documentReference.get().then((snapshot) {
  //     holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
  //     bookMarks = holdsData["bookMarkedPosts"];
  //     // print(holdsData["bookMarkedPosts"]);
  //     // print("VALUES");
  //   });
  //
  //   try {
  //     print(bookMarks.contains(postId));
  //     print(bookMarks);
  //     print(postId);
  //     print("ENDz");
  //     if (bookMarks.contains(postId)) {
  //       // if the likes list contains the user uid, we need to remove it
  //       _firestore.collection('users').doc(uid).update({
  //         'bookMarkedPosts' : FieldValue.arrayRemove([postId])
  //       });
  //     } else {
  //       // else we need to add uid to the likes array
  //       _firestore.collection('users').doc(uid).update({
  //         'bookMarkedPosts' : FieldValue.arrayUnion([postId])
  //       });
  //     }
  //     res = 'success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }

  // Post comment

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}