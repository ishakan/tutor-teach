// import 'dart:collection';
// import 'dart:ffi';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_firebase_signin/resources/firestore_methods.dart';
// import 'package:google_firebase_signin/screens/seecode.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_firebase_signin/allConstants/all_constants.dart';
// import 'package:google_firebase_signin/allConstants/app_constants.dart';
// import 'package:google_firebase_signin/allWidgets/loading_view.dart';
// import 'package:google_firebase_signin/models/chat_user.dart';
// import 'package:google_firebase_signin/providers/profile_provider.dart';
//
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);
//
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// List<Item> generateItems(int numberOfItems) {
//   return List<Item>.generate(numberOfItems, (int index) {
//     return Item(
//       headerValue: 'Panel $index',
//       expandedValue: 'This is item number $index',
//     );
//   });
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController? displayNameController, aboutMeController, isTutorController, testingController;
//   final TextEditingController _phoneController = TextEditingController();
//
//   late String currentUserId;
//   String dialCodeDigits = '+00', id = '', displayName = '';
//   String photoUrl = '';
//   String phoneNumber = '';
//   String aboutMe = '';
//   String testing = '';
//   String isTutor = '';
//
//   bool isPageLoading = false;
//   bool isLoading = false, value = false;
//   File? avatarImageFile;
//   late ProfileProvider profileProvider;
//   CompanyWidget? company;
//   final FocusNode focusNodeNickname = FocusNode();
//
//   CollectionReference _collectionRef =
//   FirebaseFirestore.instance.collection('subjects');
//
//
//   late GlobalKey<ScaffoldState> _key;
//   late bool _isSelected;
//   late List<CompanyWidget> _companies;
//   late List<String> _filters;
//   late List<String> _choices;
//   late int _choiceIndex;
//
//   // late Map<String, bool> allSubjectsState;
//
//   List<String> allSubjects = [];
//   late Map<String, bool> allSubjectStates = {};
//
//   @override
//   void initState()  {
//     super.initState();
//     profileProvider = context.read<ProfileProvider>();
//     forAsync();
//   }
//
//   void forAsync() async {
//     _filters = <String>[];
//     _key = GlobalKey<ScaffoldState>();
//     _isSelected = false;
//     _choiceIndex = 0;
//     print(allSubjects);
//     await getSubjects();
//     id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
//
//
//     _companies = <CompanyWidget>[];
//     for (int i =0; i < allSubjects.length; i++) {
//       _companies.add(CompanyWidget(allSubjects[i]));
//     }
//
//     int lenOfList = allSubjects.length - 1;
//     for (int i =0; i < lenOfList; i++) {
//       bool checkState = await getDataForSubject(false, allSubjects[i]);
//       allSubjectStates[allSubjects[i]] = checkState;
//       if (checkState == true) {
//         _filters.add(allSubjects[i]);
//       }
//       print(allSubjects[i] + allSubjectStates[allSubjects[i]].toString());
//     }
//     isPageLoading = true;
//     readLocal();
//
//     print("FILTERS");
//     print(_filters);
//   }
//
//   Future<void> getSubjects() async {
//     final QuerySnapshot result =
//     await FirebaseFirestore.instance.collection('subjects').get();
//     final List<DocumentSnapshot> documents = result.docs;
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("subjects").get();
//     for (int i = 0; i < querySnapshot.docs.length; i++) {
//       allSubjects.add(querySnapshot.docs[i].id.toString());
//     }
//   }
//
//
//   Future<bool> getDataForSubject(bool state, String name) async {
//     var collection = FirebaseFirestore.instance.collection('subjects');
//     var docSnapshot = await collection.doc(name).get();
//     if (docSnapshot.exists) {
//       Map<String, dynamic>? data = docSnapshot.data();
//       print(data);
//       print("getDataForSubject");
//       // var value = data?['some_field']; // <-- The value you want to retrieve.
//       // Call setState if needed.
//     }
//     // DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('subjects').doc(name).get();
//     // print(snapshot);
//     // // return snapshot.then((value) => Pet.fromSnapshot(value).specie);
//     //
//     // DocumentReference documentReference = FirebaseFirestore.instance.collection('subjects').doc(name);
//     // String specie;
//     // await documentReference.get().then((snapshot) {
//     //   print(snapshot.data());
//     //   // specie = snapshot.data['type'].toString();
//     // });
//     // // return specie
//     //
//     // var collection = FirebaseFirestore.instance.collection('subjects');
//     // var docSnapshot = await collection.doc(name).get();
//     // if (docSnapshot.exists) {
//     //   Map<dynamic, dynamic> data = docSnapshot.data()!;
//     //
//     //   // You can then retrieve the value from the Map like this:
//     //   // var name = data['name'];
//     //   print(data);
//     //   print("getDataForSubject");
//     // }
//     return false;
//
//     // late LinkedHashMap<String, dynamic> holdsData;
//     //
//     // DocumentReference documentReference = FirebaseFirestore.instance.collection('subjects').doc(name);
//     // List values = [], holder = [];
//     // await documentReference.get().then((snapshot) {
//     //   print(snapshot.data());
//     //   holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
//     //   values = holdsData.values.toList();
//     // });
//     // holder = values[0];
//     // print("getDataForSubject");
//     // print(holder);
//     // print(values[1]);
//     // print(name);
//     // print(holder.contains(id));
//     // if (holder.contains(id)) {
//     //   return true;
//     // } else { return false; }
//   }
//
//   void readLocal() async {
//     setState(() {
//       id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
//       displayName = profileProvider.getPrefs(FirestoreConstants.displayName) ?? "";
//
//       photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
//       phoneNumber = profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
//       aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";
//       testing = profileProvider.getPrefs(FirestoreConstants.testing) ?? "";
//       isTutor = profileProvider.getPrefs(FirestoreConstants.isTutor) ?? "";
//       print("is Tutor??");
//       print(profileProvider.getPrefs(FirestoreConstants.isTutor).toString() + " letssee");
//       print(profileProvider.getPrefs(FirestoreConstants.testing).toString());
//
//     });
//
//     print(aboutMe);
//     print(id);
//     print("ALL STATES");
//     displayNameController = TextEditingController(text: displayName);
//     aboutMeController = TextEditingController(text: aboutMe);
//     testingController = TextEditingController(text: testing);
//     isTutorController = TextEditingController(text: isTutor);
//   }
//
//   Future getImage() async {
//     ImagePicker imagePicker = ImagePicker();
//     XFile? pickedFile = await imagePicker
//         .pickImage(source: ImageSource.gallery)
//         .catchError((onError) {
//       Fluttertoast.showToast(msg: onError.toString());
//     });
//     File? image;
//     if (pickedFile != null) {
//       image = File(pickedFile.path);
//     }
//     if (image != null) {
//       setState(() {
//         avatarImageFile = image;
//         isLoading = true;
//       });
//       uploadFile();
//     }
//   }
//
//   Future uploadFile() async {
//     String fileName = id;
//     UploadTask uploadTask = profileProvider.uploadImageFile(
//         avatarImageFile!, fileName);
//     try {
//       TaskSnapshot snapshot = await uploadTask;
//       photoUrl = await snapshot.ref.getDownloadURL();
//       ChatUser updateInfo = ChatUser(id: id,
//           photoUrl: photoUrl,
//           displayName: displayName,
//           phoneNumber: phoneNumber,
//           aboutMe: aboutMe,
//           testing: testing,
//           isTutor: isTutor);
//       profileProvider.updateFirestoreData(
//           FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
//           .then((value) async {
//         await profileProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
//         setState(() {
//           isLoading = false;
//         });
//       });
//     } on FirebaseException catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//   void updateFirestoreData() {
//     for (int i =0; i < allSubjects.length; i++) {
//       bool? initialState = allSubjectStates[allSubjects[i]];
//       if (initialState == true && _filters.contains(allSubjects[i])) {
//       } else if (initialState == true) {
//         // Filter contains == false
//         FireStoreMethods().updateSubject(allSubjects[i], id, false);
//       } else if (initialState == false && _filters.contains(allSubjects[i])) {
//         FireStoreMethods().updateSubject(allSubjects[i], id, true);
//       } else {
//         FireStoreMethods().updateSubject(allSubjects[i], id, false);
//         // initalState == false;
//       }
//     }
//     // for (CompanyWidget company in _companies) {
//     //   bool checkIfSeen = false;
//     //   for (int i =0; i < _filters.length; i++) {
//     //     if (_filters[i] == company.name) {
//     //       checkIfSeen = true;
//     //     }
//     //   }
//     //
//     // }
//
//     focusNodeNickname.unfocus();
//     setState(() {
//       isLoading = true;
//       if (dialCodeDigits != "+00" && _phoneController.text != "") {
//         phoneNumber = dialCodeDigits + _phoneController.text.toString();
//       }
//     });
//     ChatUser updateInfo = ChatUser(id: id,
//         photoUrl: photoUrl,
//         displayName: displayName,
//         phoneNumber: phoneNumber,
//         aboutMe: aboutMe,
//         testing: testing,
//         isTutor: isTutor);
//     profileProvider.updateFirestoreData(
//         FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
//         .then((value) async {
//       await profileProvider.setPrefs(
//           FirestoreConstants.displayName, displayName);
//       await profileProvider.setPrefs(
//           FirestoreConstants.phoneNumber, phoneNumber);
//       await profileProvider.setPrefs(
//         FirestoreConstants.photoUrl, photoUrl,);
//       await profileProvider.setPrefs(
//           FirestoreConstants.aboutMe,aboutMe );
//       await profileProvider.setPrefs(
//           FirestoreConstants.testing,testing );
//       await profileProvider.setPrefs(
//           FirestoreConstants.isTutor, isTutor);
//       setState(() {
//         isLoading = false;
//       });
//       Fluttertoast.showToast(msg: 'UpdateSuccess');
//     }).catchError((onError) {
//       Fluttertoast.showToast(msg: onError.toString());
//     });
//   }
//
//   void _onRememberMeChanged(bool? newValue) => setState(() {
//     if (newValue!) {
//       testing = "yes";
//     } else if (!newValue!) {
//       testing = "no";
//     }
//     // onChanged: (value) {
//     //   testing = value;
//     // },
//     value = newValue!;
//     if (value == false) {
//       isTutor = "";
//     } else {
//       isTutor = "yes";
//     }
//     // if (rememberMe) {
//     //   // TODO: Here goes your functionality that remembers the user.
//     // } else {
//     //   // TODO: Forget the user
//     // }
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     print("IS THIS PRINTING??");
//     if (isTutor == "yes") {
//       value = true;
//     }
//     return (!isPageLoading) ? Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "EdiFly",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
//             ),
//             Image.asset(
//               'assets/images/splash.png',
//               width: 300,
//               height: 300,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             const Text(
//               "Profile Page",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             const CircularProgressIndicator(
//               color: AppColors.lightGrey,
//             ),
//           ],
//         ),
//       ),
//     ) :
//     Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           AppConstants.profileTitle,
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 GestureDetector(
//                   onTap: getImage,
//                   child: Container(
//                     alignment: Alignment.center,
//                     child: avatarImageFile == null ? photoUrl.isNotEmpty ?
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(60),
//                       child: Image.network(photoUrl,
//                         fit: BoxFit.cover,
//                         width: 120,
//                         height: 120,
//                         errorBuilder: (context, object, stackTrace) {
//                           return const Icon(Icons.account_circle, size: 90,
//                             color: AppColors.greyColor,);
//                         },
//                         loadingBuilder: (BuildContext context, Widget child,
//                             ImageChunkEvent? loadingProgress) {
//                           if (loadingProgress == null) {
//                             return child;
//                           }
//                           return SizedBox(
//                             width: 90,
//                             height: 90,
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.grey,
//                                 value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes! : null,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ) : const Icon(Icons.account_circle,
//                       size: 90,
//                       color: AppColors.greyColor,)
//                         : ClipRRect(
//                       borderRadius: BorderRadius.circular(60),
//                       child: Image.file(avatarImageFile!, width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,),),
//                     margin: const EdgeInsets.all(20),
//                   ),),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Text('Name', style: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.spaceCadet,
//                     ),),
//                     TextField(
//                       decoration: kTextInputDecoration.copyWith(
//                           hintText: 'Write your Name'),
//                       controller: displayNameController,
//                       enabled: false,
//                       readOnly: true,
//                       onChanged: (value) {
//                         displayName = value;
//                       },
//                       focusNode: focusNodeNickname,
//                     ),
//                     vertical15,
//                     const Text('Grade Level', style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.spaceCadet
//                     ),),
//                     // const T
//                     TextField(
//                       decoration: InputDecoration(
//                         border: UnderlineInputBorder(),
//                         hintText: '# Grade',
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.indigo),
//                         ),
//                       ),
//                       // decoration: kTextInputDecoration.copyWith(
//                       //   hintText: '# Grade',
//                       controller: aboutMeController,
//                       // decoration: kTextInputDecoration.copyWith(
//                       //     hintText: 'Write about yourself...'),
//                       onChanged: (value) {
//                         aboutMe = value;
//                       },
//                     ),
//                     vertical15,
//                     CheckboxListTile(
//                       activeColor: Colors.indigo,
//                       title: const Text('Are you a tutor?'),
//                       value: value, onChanged: _onRememberMeChanged,
//                       secondary: const Icon(Icons.person_add),
//                     ),
//                     // Checkbox(value: value, onChanged: _onRememberMeChanged),
//                     Column(
//                       // crossAxisAlignment: CrossAxisAlignment.center,
//                       // mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Visibility(
//                           visible: value,
//                           child: Column(
//                               children: <Widget>[
//                                 const Text('Click the subjects that you can teach:', style: TextStyle(
//                                   fontStyle: FontStyle.italic,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.spaceCadet,
//                                 ),
//                                 ),
//                                 Wrap(
//                                   // alignment: WrapAlignment.center,
//                                   children: companyPosition.toList(),
//                                 ),
//                               ]
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//                 vertical15,
//                 ElevatedButton(style: ElevatedButton.styleFrom(
//                     primary: AppColors.indyBlue),
//                     onPressed: updateFirestoreData, child:const Padding(
//                       padding:  EdgeInsets.all(8.0),
//                       child:  Text('Update Info'),
//                     )),
//               ],
//             ),
//           ),
//           Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
//         ],
//       ),
//
//     );
//   }
//
//   Iterable<Widget> get companyPosition sync* {
//     for (CompanyWidget company in _companies) {
//       yield Padding(
//         padding: const EdgeInsets.all(1.0),
//         child: FilterChip(
//           backgroundColor: Colors.orangeAccent,
//           avatar: CircleAvatar(
//             backgroundColor: Colors.orange,
//             child: Text(company.name[0].toUpperCase(),style: TextStyle(color: Colors.white, fontSize: 12),),
//           ),
//           label: Text(company.name, style: TextStyle(fontSize: 12),),
//           selected: _filters.contains(company.name),selectedColor: Colors.redAccent,
//           onSelected: (bool selected) {
//             setState(() {
//               if (selected) {
//                 _filters.add(company.name);
//               } else {
//                 _filters.removeWhere((String name) {
//                   return name == company.name;
//                 });
//               }
//             });
//           },
//         ),
//       );
//     }
//   }
//
// }
//
// class CompanyWidget {
//   const CompanyWidget(this.name);
//   final String name;
// }
