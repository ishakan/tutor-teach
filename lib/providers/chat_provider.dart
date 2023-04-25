import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_firebase_signin/models/bad_messages.dart';
import 'package:google_firebase_signin/models/message_model.dart';
import 'package:google_firebase_signin/models/push_notification.dart';
import 'package:google_firebase_signin/notification_service.dart';
import 'package:mailer/mailer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_messages.dart';
import 'package:http/http.dart' as http;


// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.prefs,
      required this.firebaseStorage,
      required this.firebaseFirestore});


  /**
   * uplods image onto firebase storage
   * @param image
   * @param filename
   */

  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  /**
   * updates Data from Firestroe by using collectionPath
   * @param collectionPath
   * @param docpath
   * @param dataUpdate
   */

  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit, String schoolName) {
    return firebaseFirestore
        .collection('schools').doc(schoolName)
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }


  Future<List<String>> getChattedWith(String id, String schoolName) async {
    List<String> holder = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('schools').doc(schoolName).collection("users").doc(id).collection("userMessaged").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      String subjectName = querySnapshot.docs[i].id.toString();
      holder.add(subjectName);
    }
    print(holder);
    print("GET CHATTED WITH");
    return holder;
  }

  Future<Map<String, dynamic>> getCharacteristics(String peerId, String schoolName) async {
    Map<String, dynamic> holder = {};
    var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection("users");
    var docSnapshot = await collection.doc(peerId).get();
    if (docSnapshot.exists) {
      holder = docSnapshot.data() ?? {};
    }
    return holder;
  }

  Future<Map<String, dynamic>> getFcmToken(String peerId, String schoolName) async {
    Map<String, dynamic> holder = {};
    var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection("users");
    var docSnapshot = await collection.doc(peerId).get();
    if (docSnapshot.exists) {
      holder = docSnapshot.data() ?? {};
    }
    return holder;
  }

  void sendNotification(String title, String body, String deviceToken) async {
    final data = {
      "notification": {"body": "$body", "title": "$title"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": "$deviceToken"
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=AAAAbe7FRrU:APA91bEjD-M6m3SUXfQUmu9FApb_aWaEKQv-gUrn6iR7H70FcYAzm8xfbdY3Yanat5vrKmGyE-Bj9Dr7aHjti_gU9EoWsnN2z-f7i5sxKE_8AhfiZp__hpyA1dcY4WeUUQArtywakaGt'
    };
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: json.encode(data),
      headers: headers,
    );
    if (response.statusCode == 200) {
      print('notification sent');
    } else {
      print('error: ${response.statusCode}');
    }
  }

  // Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   print("Handling a background message: ${message.messageId}");
  // }

  // void requestAndRegisterNotification() async {
  //
  //   _messaging = FirebaseMessaging.instance;
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // }

  void sendChatMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId, String schoolName) async {


    // creating documetn of groupchat id
    DocumentReference _SchooldocRef =
    firebaseFirestore.collection('schools').doc(schoolName);

   await _SchooldocRef.collection('messages').doc(groupChatId).get().then((DocumentSnapshot documentSnapshot) {
     if (!documentSnapshot.exists) {
       String res = "Some error occurred";
       try {
         MessageModel post = MessageModel(
           user_one: currentUserId,
           user_two: peerId,
         );
         _SchooldocRef.collection('messages').doc(groupChatId).set(post.toJson());
         res = "success";
       } catch (err) {
         res = err.toString();
       }
     }
   }).catchError((error) {
     print('Error retrieving document: $error');
   });

    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management

    String fcmToken = "";
    DocumentReference documentReference = firebaseFirestore
        .collection('schools').doc(schoolName)
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


    List<String> allIds = await getChattedWith(currentUserId, schoolName);
    print(allIds);
    String state = "";
    print("ALL THE IDS");
    state = "unblocked";

    int time = DateTime.now().millisecondsSinceEpoch;
    time *= -1;

    Map<String, dynamic> holder2 = await getCharacteristics(peerId, schoolName);
    fcmToken = holder2["fcmToken"];
    print(fcmToken);
    print(holder2);
    print("TOKEN INFO");
    if (type == MessageType.image) {
      content = "[Image]";
    }
    print(type);
    print(" THIS IS THE TYPE");
    print(content);
    if (!allIds.contains(peerId)) {
      Map<String, dynamic> holder = await getCharacteristics(peerId, schoolName);
      String photoUrl = "", peerName = "";
      photoUrl = holder["photoUrl"];
      peerName = holder["displayName"];
      var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(currentUserId).collection("userMessaged");
      collection
          .doc(peerId) // <-- Document ID
          .set(
        {'idTo': peerId, 'timestamp' : time, 'previousMessage' : content, "photoUrl" : photoUrl, "peerName" : peerName, "state" : state},
      ) // <-- Your data
          .then((_) => print('Added'))
          .catchError((error) => print('Add failed: $error'));

      holder = await getCharacteristics(currentUserId, schoolName);
      photoUrl = "";
      peerName = "";
      photoUrl = holder["photoUrl"];
      peerName = holder["displayName"];
      var collection2 = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users').doc(peerId).collection("userMessaged");
      collection2
          .doc(currentUserId) // <-- Document ID
          .set(
        {'idTo': currentUserId, 'timestamp' : time, 'previousMessage' : content, "photoUrl" : photoUrl, "peerName" : peerName, "state" : state},
      ) // <-- Your data
          .then((_) => print('Added'))
          .catchError((error) => print('Add failed: $error'));
    } else {
      FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users')
          .doc(currentUserId).collection('userMessaged').doc(peerId)
          .update({'previousMessage': content, 'timestamp' : time});

      FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users')
          .doc(peerId).collection('userMessaged').doc(currentUserId)
          .update({'previousMessage': content, 'timestamp' : time});
    }
    // var collection = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection("userMessaged");
    // collection
    //     .doc('test') // <-- Document ID
    //     .set({'age': 20}) // <-- Your data
    //     .then((_) => print('Added'))
    //     .catchError((error) => print('Add failed: $error'));

    print("printing?");
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    });

    print(fcmToken);
    sendNotification("Message", content, fcmToken);
    // LocalNotificationService.sendNotification(title: "New message", message: content, token: fcmToken);

  }

  void updateBadMessage(String content, int type,
      String currentUserId, String peerId, String schoolName) async {
    var collection = FirebaseFirestore.instance.collection('schools').doc(schoolName).collection('users');
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
        .collection('schools').doc(schoolName)
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
