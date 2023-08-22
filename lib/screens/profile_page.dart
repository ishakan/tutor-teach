import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_firebase_signin/models/report_user.dart';
import 'package:google_firebase_signin/models/waiting_model.dart';
import 'package:google_firebase_signin/models/waiting_model2.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/screens/contact_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/seecode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allWidgets/loading_view.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';

import '../login/fluttter_engine_group.dart';


class ProfilePage extends StatefulWidget {
  // const scienceFeedScreen({Key? key}) : super(key: key);
  final String schoolName;
  // final bool isAdmin;
  const ProfilePage({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class Item {
  Item({
    required this.headerValue,
    this.isExpanded = false,
  });

  String headerValue;
  bool isExpanded;
}


/**
 * generates all titles for subjects displayed in users profile page
 */

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    String title = "";
    if (index == 0) {
      title = "Science";
    } else if (index == 1) {
      title = "Math";
    } else if (index == 2) {
      title = "Humanities";
    } else if (index == 3) {
      title = "Language";
    } else {
      title = "Literature";
    }
    return Item(
      headerValue: title,
    );
  });
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController? displayNameController, aboutMeController, isTutorController, testingController;
  final TextEditingController _phoneController = TextEditingController();

  late DocumentReference _SchooldocRef;

  late String currentUserId;
  String dialCodeDigits = '+00', id = '', displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';
  String testing = '';
  String isTutor = '';
  String email = '';
  String schoolName = "";
  String fcmToken = "fcmToken";
  String approved = "";
  bool _isRecording = false;
  bool isTapped = false;
  String textForApproval = "Request Approval for becoming a Tutor";

  bool isPageLoading = false;
  bool isLoading = false, value = false;
  File? avatarImageFile;
  late ProfileProvider profileProvider;
  late AuthProvider authProvider;
  final FocusNode focusNodeNickname = FocusNode();

  late CollectionReference _collectionRef;

  late GlobalKey<ScaffoldState> _key;
  late bool _isSelected;
  late List<CompanyWidget> _companies, scienceCompany, mathCompany, languageCompany, literatureCompany, humanitiesCompany;
  late List<String> _filters;
  late List<String> _choices;
  late int _choiceIndex;

  // late Map<String, bool> allSubjectsState;

  List<String> allSubjects = [];
  late Map<String, bool> allSubjectStates = {};
  late Map<String, String> allSubjectTypes = {};

  @override
  void initState()  {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    authProvider = context.read<AuthProvider>();
    _SchooldocRef =  FirebaseFirestore.instance.collection('schools').doc(widget.schoolName);
    _collectionRef = FirebaseFirestore.instance.collection('schools').doc(widget.schoolName).collection('subjects');
    forAsync();
  }

  void forAsync() async {
    _filters = <String>[];
    _key = GlobalKey<ScaffoldState>();
    _isSelected = false;
    _choiceIndex = 0;
    print(allSubjects);
    id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
    await getSubjects();


    _companies = <CompanyWidget>[];
    scienceCompany = <CompanyWidget>[];
    mathCompany = <CompanyWidget>[];
    languageCompany = <CompanyWidget>[];
    literatureCompany = <CompanyWidget>[];
    humanitiesCompany = <CompanyWidget>[];

    for (int i =0; i < allSubjects.length; i++) {
      String subject  = allSubjects[i];
      subject = subject.replaceAll("_", "");
      if (allSubjectTypes[allSubjects[i]] == "Science") {
        scienceCompany.add(CompanyWidget(allSubjects[i]));
      } else if (allSubjectTypes[allSubjects[i]] == "Language") {
        languageCompany.add(CompanyWidget(allSubjects[i]));
      } else if (allSubjectTypes[allSubjects[i]] == "Literature") {
        literatureCompany.add(CompanyWidget(allSubjects[i]));
      } else if (allSubjectTypes[allSubjects[i]] == "Math") {
        mathCompany.add(CompanyWidget(allSubjects[i]));
      } else {
        humanitiesCompany.add(CompanyWidget(allSubjects[i]));
      }
      _companies.add(CompanyWidget(allSubjects[i]));
    }

    await readLocal();
    int lenOfList = allSubjects.length - 1;
    for (int i =0; i < lenOfList; i++) {
      if (allSubjectStates[allSubjects[i]] == true) {
        _filters.add(allSubjects[i]);
      }
      print(allSubjects[i] + allSubjectStates[allSubjects[i]].toString());
    }
    isPageLoading = true;

    print(approved);
    print("FIRST ITERATION");
    if (approved == "approved") {
      await setApproval();
    }
    print(approved);

    if (approved != "waiting") {
      textForApproval = "Request Approval for becoming a Tutor";
    } else {
      textForApproval = "Waiting for Approval...";
    }

    print("APPROVAL");
    print(approved);

    print("FILTERS");
    print(_filters);
  }

  /**
   * gets all courses for any subject
   */

  Future<bool> setApproval() async {
    bool needsApproval = false;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('schools').get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      Map<String, dynamic> allData = snapshot.docs[i].data();
      if (snapshot.docs[i].id == schoolName) {
        print(allData["needApproval"]);
        print("What ??");
        print(allData);
        if (allData["needApproval"] == "yes") {
          needsApproval = true;
        }
        break;
      }
    }
    return needsApproval;
  }

  Future<void> getSubjects() async {
    final QuerySnapshot result =
    await _SchooldocRef.collection('subjects').get();
    final List<DocumentSnapshot> documents = result.docs;
    QuerySnapshot querySnapshot = await _SchooldocRef.collection("subjects").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      String subjectName = querySnapshot.docs[i].id.toString();
      allSubjects.add(subjectName);
      Map<String, dynamic> data = querySnapshot.docs[i].data() as Map<String, dynamic>;
      List<dynamic> holdId = data[subjectName];
      allSubjectStates[subjectName] = holdId.contains(id);
      print(allSubjectStates[subjectName]);
      print("ALL SUBJECT STATES");
      if (data["type"] != null) {
        allSubjectTypes[subjectName] = data["type"];
      } else {
        allSubjectTypes[subjectName] = "None";
      }
    }
  }

  /**
   * initializes all base varaibles
   */

  Future<void> readLocal() async {
    currentUserId = authProvider.getFirebaseUserId()!;
    print(currentUserId);
    late LinkedHashMap<String, dynamic> holdsData;
    DocumentReference documentReference = _SchooldocRef.collection('users').doc(id);
    await documentReference.get().then((snapshot) {
      holdsData = snapshot.data() as LinkedHashMap<String, dynamic>;
    });

    bool needsApproval = await setApproval();
    if (!needsApproval) {
      // approved
    }

    print(holdsData);
    setState(() {
      id = holdsData["id"] ?? "";
      displayName = holdsData["displayName"] ?? "";
      photoUrl = holdsData["photoUrl"] ?? "";
      phoneNumber = holdsData["phoneNumber"] ?? "";
      aboutMe = holdsData["aboutMe"] ?? "";
      testing = holdsData["testing"] ?? "";
      isTutor = holdsData["isTutor"] ?? "";
      email = holdsData["email"] ?? "";
      schoolName = holdsData["schoolName"] ?? "";
      fcmToken = holdsData["fcmToken"] ?? "fcmToken";
      approved = holdsData["approved"] ?? "";
    });


    print(aboutMe);
    print(id);
    print("ALL STATES");
    displayNameController = TextEditingController(text: displayName);
    aboutMeController = TextEditingController(text: aboutMe);
    testingController = TextEditingController(text: testing);
    isTutorController = TextEditingController(text: isTutor);
  }


  Future getImage() async {

  }

  /**
   * makes sure all requirements are met to sign up as tutor
   */

  deleteAccount(String uid) async {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        await FireStoreMethods().deleteAccount(schoolName, uid, authProvider);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FlutterEngineGroup()));

        },
    );
    Widget cancel = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete?"),
      content: Text("Are you sure you want to delete your account? This action cannot be reversed."),
      actions: [
        okButton,
        cancel,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Not Finished!"),
      content: Text("Tutors need to have their Grade Level inputted."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /**
   * updates user Information
   */

  void updateFirestoreData() {
    if (isTutor == "yes" && aboutMe.length == 0) {
      showAlertDialog(context);
    } else {
      if (isTutor == "yes") {
        for (int i =0; i < allSubjects.length; i++) {
          print("Subject");
          print(allSubjects[i]);
          print(allSubjectStates[allSubjects[i]]);
          if (allSubjectStates[allSubjects[i]] == true) {
            FireStoreMethods().updateSubject(allSubjects[i], id, true, widget.schoolName);
          } else if (allSubjectStates[allSubjects[i]] == false) {
            FireStoreMethods().updateSubject(allSubjects[i], id, false, widget.schoolName);
          }
        }
      } else {
        for (int i =0; i < allSubjects.length; i++) {
          print("Subject");
          print(allSubjects[i]);
          print(allSubjectStates[allSubjects[i]]);
          FireStoreMethods().updateSubject(allSubjects[i], id, false, widget.schoolName);
        }
      }
      focusNodeNickname.unfocus();
      setState(() {
        isLoading = true;
        if (dialCodeDigits != "+00" && _phoneController.text != "") {
          phoneNumber = dialCodeDigits + _phoneController.text.toString();
        }
      });
      ChatUser updateInfo = ChatUser(id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe,
          testing: testing,
          isTutor: isTutor,
          email: email,
          schoolName: schoolName,
          fcmToken: fcmToken,
          approved: approved);
      profileProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, id, updateInfo.toJson(), schoolName)
          .then((value) async {
        await profileProvider.setPrefs(
            FirestoreConstants.displayName, displayName);
        await profileProvider.setPrefs(
            FirestoreConstants.phoneNumber, phoneNumber);
        await profileProvider.setPrefs(
          FirestoreConstants.photoUrl, photoUrl,);
        await profileProvider.setPrefs(
            FirestoreConstants.aboutMe,aboutMe );
        await profileProvider.setPrefs(
            FirestoreConstants.testing,testing );
        await profileProvider.setPrefs(
            FirestoreConstants.isTutor, isTutor);
        await profileProvider.setPrefs(
            FirestoreConstants.email, email);
        await profileProvider.setPrefs(
            FirestoreConstants.schoolName, schoolName);
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Update Success');
      }).catchError((onError) {
        Fluttertoast.showToast(msg: onError.toString());
      });
      setState(() {});

    }
    setState(() {});
  }

  void updateForApproval() {
    approved = "waiting";
    ChatUser updateInfo = ChatUser(id: id,
        photoUrl: photoUrl,
        displayName: displayName,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe,
        testing: testing,
        isTutor: isTutor,
        email: email,
        schoolName: schoolName,
        fcmToken: fcmToken,
        approved: approved);

    profileProvider.updateFirestoreData(
        FirestoreConstants.pathUserCollection, id, updateInfo.toJson(), schoolName)
        .then((value) async {
      await profileProvider.setPrefs(
          FirestoreConstants.aboutMe, aboutMe);
      await profileProvider.setPrefs(
          FirestoreConstants.approved, approved);
      setState(() {
        isLoading = false;
      });
      // Fluttertoast.showToast(msg: 'Update Success');
    }).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
  }

  Future<String> uploadToWaiting(String name, String uid, String gradeLevel, String fcmToken, String photoUrl) async {
    print("running?");
    print(name);
    print(uid);
    print(gradeLevel);
    print(fcmToken);
    DocumentReference _SchooldocRef =
    _firestore.collection('schools').doc(schoolName);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    print(now);
    print(formattedDate);
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      timestamp *= -1;
      String postId = timestamp.toString();
      print(postId);
      print(uid);
      print(name);
      print(formattedDate);
      print(gradeLevel);
      print(fcmToken);
      WaitingModel2 report = WaitingModel2(
        databaseid_stored: postId,
        personid_waiting: uid,
        name_waiting: name,
        timestamp_waiting: formattedDate,
        gradeLevel_waiting: gradeLevel,
        fcmToken_waiting: fcmToken,
        photoUrl_waiting: photoUrl,
      );
      _SchooldocRef.collection('waiting').doc(postId).set(report.toJson());
      // WaitingModel waitingModel = const WaitingModel(
      //   databaseid_stored: "a",
      //   personid_waiting: "a",
      //   name_waiting: "a",
      //   timestamp_waiting: "a",
      //   gradeLevel_waiting: "a",
      //   fcmToken_waiting: "a",
      // );
      // _SchooldocRef.collection('waiting').doc("asdf").set(waitingModel.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  void _onRememberMeChanged(bool? newValue) => setState(() {
    if (newValue!) {
      testing = "yes";
    } else if (!newValue!) {
      testing = "no";
    }
    // onChanged: (value) {
    //   testing = value;
    // },
    value = newValue!;
    if (value == false) {
      isTutor = "";
    } else {
      isTutor = "yes";
    }
    // if (rememberMe) {
    //   // TODO: Here goes your functionality that remembers the user.
    // } else {
    //   // TODO: Forget the user
    // }
  });

  @override
  Widget build(BuildContext context) {
    bool _loading = false;
    void _startLoading() {
      setState(() {
        _loading = true;
      });
      // Do some time-consuming work here
      // Once the work is done, call _stopLoading() to hide the progress indicator
    }
    print("BEFORE EE");
    print(approved);

    print("IS THIS PRINTING??");
    if (isTutor == "yes") {
        value = true;
    }
    return (!isPageLoading) ? Scaffold(
      body:
      Center(
        child: _loading ? CircularProgressIndicator() : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "EdiFly",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Gilroy', fontSize: Sizes.dimen_18),
            ),
            Image.asset(
              'assets/images/splash.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Profile Page",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Gilroy', fontSize: Sizes.dimen_18),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: AppColors.lightGrey,
            ),
          ],
        ),
      ),
    ) :
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0), // Set the height of the line
              child: Container(
                color: AppColors.greyColor, // Set the color of the line
                height: 1.0, // Set the height of the line
              ),
            ),
            title: const Text(
              'Profile Page',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.spaceLight,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w200,
                fontSize: Sizes.dimen_26,
              ),
            ),
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_sharp, size: 25, color: Colors.black)), //
            // title: const Text(
            //   AppConstants.profileTitle,
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold, fontFamily: 'Gilroy'),
            // ),
            actions: [
              PopupMenuTheme(
                data: PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  elevation: 3, // set the elevation to 0 to remove the shadow
                ),
                child: PopupMenuButton(
                  icon: Icon(Icons.settings, size: 25, color: Colors.black),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                    value: 1,
                      child: GestureDetector(
                        onTap: () {
                          _startLoading();
                          deleteAccount(currentUserId);
                        },
                        child: Text('Delete Account',
                            style: TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: 'Gilroy'),
                      ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactPage()));
                        },
                        child: Text('Contact Us',
                            style: TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: 'Gilroy'),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
              color: Colors.white, // Set the background color to white
              child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height, // Set a minimum height to fill available space
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // children: [
                  // child: Container(
                  //   color: Colors.white,
                  //   child:
                  //     Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                            alignment: Alignment.center,
                            child: avatarImageFile == null ? photoUrl.isNotEmpty ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(photoUrl,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, object, stackTrace) {
                                  return const Icon(Icons.account_circle, size: 90,
                                    color: AppColors.greyColor,);
                                },
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes! : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ) : const Icon(Icons.account_circle,
                              size: 90,
                              color: AppColors.greyColor,)
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(avatarImageFile!, width: 120,
                                height: 120,
                                fit: BoxFit.cover,),),
                            margin: const EdgeInsets.all(20),
                          ),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Name', style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: AppColors.spaceCadet,
                            ),),
                            TextField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: 'Write your Name',
                                hintStyle: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 18,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 18,
                              ),
                              controller: displayNameController,
                              onChanged: (value) {
                                displayName = value;
                              },
                              focusNode: focusNodeNickname,
                            ),

                            // TextField(
                            //   decoration: kTextInputDecoration.copyWith(
                            //       hintText: 'Write your Name',
                            //     hintStyle: TextStyle(
                            //     fontFamily: 'Gilroy',
                            //     fontSize: 18, // Adjust the font size as needed
                            //   ),),
                            //   controller: displayNameController,
                            //   enabled: false,
                            //   readOnly: true,
                            //   onChanged: (value) {
                            //     displayName = value;
                            //   },
                            //   focusNode: focusNodeNickname,
                            // ),
                            vertical15,
                            const Text('Grade Level', style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.bold,
                                color: AppColors.spaceCadet
                            ),),
                            // const T
                            TextField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: '# Grade',
                                hintStyle: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 18,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 18,
                              ),
                              keyboardType: TextInputType.number,
                              controller: aboutMeController,
                              onChanged: (value) {
                                aboutMe = value;
                              },
                            ),

                            vertical15,
                           Visibility(
                               visible: (approved != "yes"),
                               child:
                               GestureDetector(
                                 onTap: () {

                                   if (approved == "waiting") {

                                   } else if (aboutMe == "") {
                                     showAlertDialog(context);
                                   } else {
                                     setState(() {
                                       textForApproval = "Waiting for Approval...";
                                       isTapped = !isTapped;
                                       updateForApproval();
                                       uploadToWaiting(displayName, currentUserId, aboutMe, "fcmToken", photoUrl);
                                     });
                                   }

                                 },
                                 child: DecoratedBox(
                                   decoration: BoxDecoration(
                                     color: Colors.white, // Set the background color to white
                                     shape: BoxShape.rectangle,
                                     border: Border.all(width: 5.0, color: AppColors.spaceCadet),
                                     borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                   ),
                                   child: Padding(
                                     padding: EdgeInsets.all(18.0),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Icon(
                                           (approved == "waiting") ? Icons.check_circle : Icons.circle_outlined,
                                           color: Colors.green,
                                         ),
                                         SizedBox(width: 8.0),
                                         Text(
                                           textForApproval,
                                           textAlign: TextAlign.center,
                                           style: TextStyle(
                                             fontFamily: 'Gilroy',
                                             fontSize: 15.0, // Set the desired font size
                                           ),
                                         ),
                                         SizedBox(width: 8.0),
                                       ],
                                     ),
                                   ),
                                 ),
                               ),
                           ),
                           Visibility(
                             visible: (approved == "yes"),
                             child: Column(
                               children: [
                                 CheckboxListTile(
                                     activeColor: Colors.indigo,
                                     title: const Text('Are you a tutor?', style: TextStyle(fontFamily: 'Gilroy'),),
                                     value: value, onChanged: _onRememberMeChanged,
                                     secondary: const Icon(Icons.person_add),
                                 ),
                                 // Checkbox(value: value, onChanged: _onRememberMeChanged),
                                 Column(
                                   // crossAxisAlignment: CrossAxisAlignment.center,
                                   // mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[
                                     Visibility(
                                       visible: value,
                                       child: Column(
                                           children: <Widget>[
                                             const Text('Click the subjects that you can teach:', style: TextStyle(
                                               fontStyle: FontStyle.italic,
                                               fontWeight: FontWeight.bold,
                                               fontFamily: 'Gilroy',
                                               color: AppColors.spaceCadet,
                                             ),
                                             ),
                                             vertical10,
                                             _buildPanel(),
                                             // Wrap(
                                             //   // alignment: WrapAlignment.center,
                                             //   children: companyPosition.toList(),
                                             // ),
                                           ]
                                       ),
                                     )
                                   ],
                                 ),
                               ],
                             ),
                           )
                          ],
                        ),
                        vertical15,
                        Visibility(
                            visible: (approved == "yes"),
                            child:
                            ElevatedButton(style: ElevatedButton.styleFrom(
                                primary: AppColors.indyBlue),
                                onPressed: updateFirestoreData, child:const Padding(
                                  padding:  EdgeInsets.all(8.0),
                                  child:  Text('Update Info', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.bold)),
                                )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
            ],
          ),

        );
  }
  final List<Item> _data = generateItems(5);

  /**
   * generates panels displaying subjects
   */


  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        Color titleColor = Colors.black;
        if (item.headerValue == "Science") {
          _companies = scienceCompany;
          titleColor = Color(0xFFFF7474);
        } else if (item.headerValue == "Language") {
          titleColor = Color(0xFFFFC274);
          _companies = languageCompany;
        } else if (item.headerValue == "Math") {
          titleColor = Color(0xFFFFFC91);
          _companies = mathCompany;
        } else if (item.headerValue == "Humanities") {
          titleColor = Color(0xFF72B272);
          _companies = humanitiesCompany;
        } else {
          titleColor = Color(0xFF78CEFF);
          _companies = literatureCompany;
        }
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              tileColor: titleColor,
              title: Text(item.headerValue, style: TextStyle(fontFamily: 'Gilroy'),),
            );
          },
          body: ListTile(
              // title: Text(item.headerValue),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    // alignment: WrapAlignment.center,
                    children: companyPosition.toList(),
                  ),
                ]
                // children: companyPosition.toList(),
              ),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  /**
   * builds chips dipslaying courses
   */

  Iterable<Widget> get companyPosition sync* {
    for (CompanyWidget company in _companies) {
      yield Padding(
        padding: const EdgeInsets.all(1.0),
        child: FilterChip(
          backgroundColor: Colors.orangeAccent,
          avatar: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(company.name[0].toUpperCase(),style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Gilroy'),),
          ),
          label: Text(company.name.replaceAll("_", " "), style: TextStyle(fontSize: 12, fontFamily: 'Gilroy'),),
          selected: (allSubjectStates[company.name] == true),selectedColor: Colors.redAccent,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                allSubjectStates[company.name] = true;
              } else {
                allSubjectStates[company.name] = false;
              }
            });
          },
        ),
      );
    }
  }

}

class CompanyWidget {
  const CompanyWidget(this.name);
  final String name;
}

// fix approved variable