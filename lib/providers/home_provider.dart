import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  /**
   * updates Data from Firestroe by using collectionPath
   * @param collectionPath
   * @param path
   * @param updateData
   */

  Future<void> updateFirestoreData(
      String collectionPath, String path, Map<String, dynamic> updateData) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(updateData);
  }

  /**
   * gets Data from Firestroe by using collectionPath
   * @param collectionPath
   * @param limit
   * @param textSearch
   */

  Stream<QuerySnapshot> getFirestoreData(
      String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.displayName, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }
}

// message notifications
// typing messages
// colors
// uploading onto app store!
