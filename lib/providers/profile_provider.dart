import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ProfileProvider(
      {required this.prefs,
      required this.firebaseStorage,
      required this.firebaseFirestore});

  String? getPrefs(String key) {
    return prefs.getString(key);
  }

  /**
   * sets preferences for values
   * @param key
   * @param value
   */

  Future<bool> setPrefs(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /**
   * uploads image to firebase storage
   * @param image - image file
   * @param fileNmae - name of image file
   */

  UploadTask uploadImageFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }


  /**
   * updates firestore data by using collection string and path string
   */

  Future<void> updateFirestoreData(String collectionPath, String path,
      Map<String, dynamic> dataUpdateNeeded, String schoolName) {
    return firebaseFirestore
        .collection('schools').doc(schoolName)
        .collection(collectionPath)
        .doc(path)
        .update(dataUpdateNeeded);
  }
}
