import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_firebase_signin/models/bad_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_messages.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.prefs,
      required this.firebaseStorage,
      required this.firebaseFirestore});

  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }


  Future<List<String>> getChattedWith(String id) async {
    List<String> holder = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").doc(id).collection("userMessaged").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      String subjectName = querySnapshot.docs[i].id.toString();
      holder.add(subjectName);
    }
    print(holder);
    print("GET CHATTED WITH");
    return holder;
  }

  Future<Map<String, dynamic>> getCharacteristics(String peerId) async {
    Map<String, dynamic> holder = {};
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot = await collection.doc(peerId).get();
    if (docSnapshot.exists) {
      holder = docSnapshot.data() ?? {};
    }
    return holder;
  }

  void sendChatMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    ChatMessages chatMessages = ChatMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type);

    List<String> allIds = await getChattedWith(currentUserId);
    print(allIds);
    print("ALL THE IDS");
    int time = DateTime.now().millisecondsSinceEpoch;
    time *= -1;

    if (!allIds.contains(peerId)) {
      Map<String, dynamic> holder = await getCharacteristics(peerId);
      String photoUrl = "", peerName = "";
      photoUrl = holder["photoUrl"];
      peerName = holder["displayName"];
      var collection = FirebaseFirestore.instance.collection('users').doc(currentUserId).collection("userMessaged");
      collection
          .doc(peerId) // <-- Document ID
          .set(
        {'idTo': peerId, 'timestamp' : time, 'previousMessage' : content, "photoUrl" : photoUrl, "peerName" : peerName},
      ) // <-- Your data
          .then((_) => print('Added'))
          .catchError((error) => print('Add failed: $error'));

      holder = await getCharacteristics(currentUserId);
      photoUrl = "";
      peerName = "";
      photoUrl = holder["photoUrl"];
      peerName = holder["displayName"];
      var collection2 = FirebaseFirestore.instance.collection('users').doc(peerId).collection("userMessaged");
      collection2
          .doc(currentUserId) // <-- Document ID
          .set(
        {'idTo': currentUserId, 'timestamp' : time, 'previousMessage' : content, "photoUrl" : photoUrl, "peerName" : peerName},
      ) // <-- Your data
          .then((_) => print('Added'))
          .catchError((error) => print('Add failed: $error'));
    } else {
      FirebaseFirestore.instance.collection('users')
          .doc(currentUserId).collection('userMessaged').doc(peerId)
          .update({'previousMessage': content, 'timestamp' : time});

      FirebaseFirestore.instance.collection('users')
          .doc(peerId).collection('userMessaged').doc(currentUserId)
          .update({'previousMessage': content, 'timestamp' : time});
    }
    // var collection = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection("userMessaged");
    // collection
    //     .doc('test') // <-- Document ID
    //     .set({'age': 20}) // <-- Your data
    //     .then((_) => print('Added'))
    //     .catchError((error) => print('Add failed: $error'));

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }

  void updateBadMessage(String content, int type,
      String currentUserId, String peerId) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot = await collection.doc(currentUserId).get();
    String nameFrom = "", senderPhotoUrl = "", nameTo = "", recieverPhotoUrl = "";
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;
      nameFrom = data['displayName'];
      senderPhotoUrl = data['photoUrl'];
    }

    docSnapshot = await collection.doc(peerId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;
      nameTo = data['displayName'];
      recieverPhotoUrl = data['photoUrl'];
    }
    print(nameFrom);
    print(nameTo);
    print("INFORMATION");
    int timeStamp =  DateTime.now().millisecondsSinceEpoch;
    timeStamp *= -1;

    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.badMessages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    BadMessages chatMessages = BadMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: timeStamp,
        nameFrom: nameFrom,
        nameTo: nameTo,
        senderPhoto: senderPhotoUrl,
        receiverPhoto: recieverPhotoUrl,
        content: content,
        type: type);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });
  }
}

class MessageType {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
