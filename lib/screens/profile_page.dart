import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/screens/seecode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/allWidgets/loading_view.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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

  late String currentUserId;
  String dialCodeDigits = '+00', id = '', displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';
  String testing = '';
  String isTutor = '';
  String email = '';

  bool isPageLoading = false;
  bool isLoading = false, value = false;
  File? avatarImageFile;
  late ProfileProvider profileProvider;
  final FocusNode focusNodeNickname = FocusNode();

  CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('subjects');

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

    readLocal();
    int lenOfList = allSubjects.length - 1;
    for (int i =0; i < lenOfList; i++) {
      if (allSubjectStates[allSubjects[i]] == true) {
        _filters.add(allSubjects[i]);
      }
      print(allSubjects[i] + allSubjectStates[allSubjects[i]].toString());
    }
    isPageLoading = true;

    print("FILTERS");
    print(_filters);
  }

  Future<void> getSubjects() async {
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('subjects').get();
    final List<DocumentSnapshot> documents = result.docs;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("subjects").get();
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
  //
  //
  // Future<bool> getDataForSubject(bool state, String name) async {
  //   var collection = FirebaseFirestore.instance.collection('subjects');
  //   var docSnapshot = await collection.doc(name).get();
  //   if (docSnapshot.exists) {
  //     Map<String, dynamic>? data = docSnapshot.data();
  //       print(data);
  //       print("getDataForSubject");
  //
  //   }
  //
  //   return false;
  // }

  void readLocal() async {
    setState(() {
      id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      displayName = profileProvider.getPrefs(FirestoreConstants.displayName) ?? "";

      photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
      phoneNumber = profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
      aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";
      testing = profileProvider.getPrefs(FirestoreConstants.testing) ?? "";
      isTutor = profileProvider.getPrefs(FirestoreConstants.isTutor) ?? "";
      email = profileProvider.getPrefs(FirestoreConstants.email) ?? "";
      print("is Tutor??");
      print(profileProvider.getPrefs(FirestoreConstants.isTutor).toString() + " letssee");
      print(profileProvider.getPrefs(FirestoreConstants.testing).toString());

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
    // ImagePicker imagePicker = ImagePicker();
    // XFile? pickedFile = await imagePicker
    //     .pickImage(source: ImageSource.gallery)
    //     .catchError((onError) {
    //   Fluttertoast.showToast(msg: onError.toString());
    // });
    // File? image;
    // if (pickedFile != null) {
    //   image = File(pickedFile.path);
    // }
    // if (image != null) {
    //   setState(() {
    //     avatarImageFile = image;
    //     isLoading = true;
    //   });
    //   uploadFile();
    // }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask = profileProvider.uploadImageFile(
        avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe,
          testing: testing,
          isTutor: isTutor,
          email: email);
      profileProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((value) async {
        await profileProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
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

  void updateFirestoreData() {
    if (aboutMe.length == 0) {
      showAlertDialog(context);
    } else {
      for (int i =0; i < allSubjects.length; i++) {
        print("Subject");
        print(allSubjects[i]);
        print(allSubjectStates[allSubjects[i]]);
        if (allSubjectStates[allSubjects[i]] == true) {
          FireStoreMethods().updateSubject(allSubjects[i], id, true);
        } else if (allSubjectStates[allSubjects[i]] == false) {
          FireStoreMethods().updateSubject(allSubjects[i], id, false);
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
          email: email);
      profileProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
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
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Update Success');
      }).catchError((onError) {
        Fluttertoast.showToast(msg: onError.toString());
      });
    }
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
    print("IS THIS PRINTING??");
    if (isTutor == "yes") {
        value = true;
    }
    return (!isPageLoading) ? Scaffold(
      body:
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "TutorTeach",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
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
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
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
            elevation: 0,
            title: const Text(
              AppConstants.profileTitle,
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            color: AppColors.spaceCadet,
                          ),),
                          TextField(
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Write your Name'),
                            controller: displayNameController,
                            enabled: false,
                            readOnly: true,
                            onChanged: (value) {
                              displayName = value;
                            },
                            focusNode: focusNodeNickname,
                          ),
                          vertical15,
                          const Text('Grade Level', style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: AppColors.spaceCadet
                          ),),
                          // const T
                          TextField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: '# Grade',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                              ),
                            ),
                            // decoration: kTextInputDecoration.copyWith(
                            //   hintText: '# Grade',
                            controller: aboutMeController,
                            // decoration: kTextInputDecoration.copyWith(
                            //     hintText: 'Write about yourself...'),
                            onChanged: (value) {
                              aboutMe = value;
                            },
                          ),
                          vertical15,
                         CheckboxListTile(
                           activeColor: Colors.indigo,
                           title: const Text('Are you a tutor?'),
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
                      vertical15,
                      ElevatedButton(style: ElevatedButton.styleFrom(
                          primary: AppColors.indyBlue),
                          onPressed: updateFirestoreData, child:const Padding(
                        padding:  EdgeInsets.all(8.0),
                        child:  Text('Update Info'),
                      )),
                    ],
                  ),
                ),
              Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
            ],
          ),

        );
  }
  final List<Item> _data = generateItems(5);

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
              title: Text(item.headerValue),
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


  Iterable<Widget> get companyPosition sync* {
    for (CompanyWidget company in _companies) {
      yield Padding(
        padding: const EdgeInsets.all(1.0),
        child: FilterChip(
          backgroundColor: Colors.orangeAccent,
          avatar: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(company.name[0].toUpperCase(),style: TextStyle(color: Colors.white, fontSize: 12),),
          ),
          label: Text(company.name.replaceAll("_", " "), style: TextStyle(fontSize: 12),),
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
