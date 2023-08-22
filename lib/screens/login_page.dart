import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_firebase_signin/allConstants/size_constants.dart';
import 'package:google_firebase_signin/auth_service.dart';
import 'package:google_firebase_signin/models/pair.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen.dart';
import 'package:google_firebase_signin/screens/admin/bottomBarScreen_admin.dart';
import 'package:google_firebase_signin/screens/contact_page.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/home_page.dart';
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as AppleButton;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _signUpKey = GlobalKey<FormState>();
  String isTutor = "", schoolName = "";
  TextEditingController? isTutorController;
  TextEditingController? schoolController;
  bool _isTextFieldFocused = false;
  bool _isTextFieldFocused2 = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _conformPwd = TextEditingController();

  // final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  /**
   * checking if code entered by user matches schools code
   * @params context
   */

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple();
      print('uid: ${user.uid}');
    } catch (e) {
      // TODO: Show alert here
      print(e);
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
      title: Text("Wrong code"),
      content: Text("This school code does not exist"),
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
   * setting state of sign up for any user
   * @params context
   */


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: 'Sign in failed');
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: 'Sign in cancelled');
        break;
      case Status.authenticated:
        // Fluttertoast.showToast(msg: 'Sign in successful');
        break;
      default:
        break;
    }

    return Scaffold(
      body:
      Stack(
        children: [
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.dimen_30,
              horizontal: Sizes.dimen_20,
            ),
            children: [
              SizedBox(height: 40.0),
              const Text(
                'Welcome to EdiFly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w800,
                  fontSize: Sizes.dimen_26,
                ),
              ),
              // const Text(
              //   'Welcome to EdiFly',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: Sizes.dimen_26,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              vertical20,
              const Text(
                'Login to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  fontSize: Sizes.dimen_22,
                ),
              ),
              // const Text(
              //   'Login to continue',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: Sizes.dimen_22,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              vertical30,
              Center(child: Image.asset('assets/images/back.png')),
              vertical10,
              Container(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTextFieldFocused = true;
                    });
                  },
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'School Name',
                      hintStyle: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 18, // Adjust the font size as needed
                      ),
                    ),
                    style: TextStyle(fontFamily: 'Gilroy'),
                    controller: schoolController,
                    onChanged: (value) {
                      schoolName = value;
                    },
                    onTap: () {
                      setState(() {
                        _isTextFieldFocused = true;
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _isTextFieldFocused = false;
                      });
                    },
                  ),

                ),
              ),


              // const Text('Enter school name:', style: TextStyle(
              //   fontStyle: FontStyle.italic,
              //   fontWeight: FontWeight.bold,
              //   color: AppColors.spaceCadet,
              // ),),
              // TextField(
              //   decoration: kTextInputDecoration.copyWith(
              //       hintText: 'School Name'),
              //   controller: schoolController,
              //   // decoration: kTextInputDecoration.copyWith(
              //   //     hintText: 'Write about yourself...'),
              //   onChanged: (value) {
              //     schoolName = value;
              //   },
              // ),
              vertical10,
              Container(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTextFieldFocused2 = true;
                    });
                  },
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'School Code',
                      hintStyle: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 18, // Adjust the font size as needed
                      ),
                    ),
                    style: TextStyle(fontFamily: 'Gilroy'),
                    controller: isTutorController,
                    onChanged: (value) {
                      isTutor = value;
                    },
                    onTap: () {
                      setState(() {
                        _isTextFieldFocused2 = true;
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _isTextFieldFocused2 = false;
                      });
                    },
                  ),

                ),
              ),
              // const Text('Enter school code:', style: TextStyle(
              //   fontStyle: FontStyle.italic,
              //   fontWeight: FontWeight.bold,
              //   color: AppColors.spaceCadet,
              // ),),
              // TextField(
              //   decoration: kTextInputDecoration.copyWith(
              //       hintText: '#######'),
              //   controller: isTutorController,
              //   // decoration: kTextInputDecoration.copyWith(
              //   //     hintText: 'Write about yourself...'),
              //   onChanged: (value) {
              //     isTutor = value;
              //   },
              // ),
              vertical10,
              GestureDetector(
                onTap: () async {
                  bool checkIfGood = false;
                  String hasToHave = "";
                  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('schools').get();
                  for (int i = 0; i < snapshot.docs.length; i++) {
                    Map<String, dynamic> allData = snapshot.docs[i].data();
                    if (snapshot.docs[i].id == schoolName) {
                      hasToHave = allData["inEmail"];
                      if (allData["code"] == isTutor) {
                        checkIfGood = true;
                      } else { break; }
                    }
                  }

                  if (!checkIfGood) {
                    showAlertDialog(context);
                  } else {
                    // bool accepted = await authProvider.showAlertDialog(context);
                    // if (accepted) {
                    Pair isSuccess = await authProvider.handleGoogleSignIn(schoolName, hasToHave, context);

                    // bool isAdmin = await authProvider.isAdminEmail();
                    if (isSuccess.item1 == true && isSuccess.item2 == true) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => bottomBarScreenAdmin(schoolName: schoolName,)));
                    } else if (isSuccess.item1 == true) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => bottomBarScreen(schoolName: schoolName,)));
                    }
                    // else {
                    //   // authProvider.status = Status.authenticateCanceled;
                    // }
                    // }
                  }
                },
                child: Image.asset('assets/images/google_login4.png'),
              ),
              Column(
                children: [
                  // AppleButton.AppleSignInButton(
                  //   style: AppleButton.ButtonSty
                  //
                  //   le.black,
                  //   type: AppleButton.ButtonType.signIn,
                  //   onPressed: () async {
                  //     try {
                  //
                  //       bool checkIfGood = false;
                  //       String hasToHave = "";
                  //       QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('schools').get();
                  //       for (int i = 0; i < snapshot.docs.length; i++) {
                  //         Map<String, dynamic> allData = snapshot.docs[i].data();
                  //         if (snapshot.docs[i].id == schoolName) {
                  //           hasToHave = allData["inEmail"];
                  //           if (allData["code"] == isTutor) {
                  //             checkIfGood = true;
                  //           } else { break; }
                  //         }
                  //       }
                  //       if (!checkIfGood) {
                  //         showAlertDialog(context);
                  //       } else {
                  //         final user = await authProvider.signInWithApple();
                  //
                  //         Navigator.pushReplacement(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => bottomBarScreen(schoolName: schoolName,)));
                  //
                  //         print('uid: ${user.uid}');
                  //       }
                  //     } catch (e) {
                  //       // TODO: Show alert here
                  //       print(e);
                  //     }
                  //   }
                  //   // onPressed: appleLogIn,
                  // )
                  // if (appleSignInAvailable.isAvailable)
                  //   AppleSignInButton(
                  //     // style: ButtonStyle.black,
                  //     type: ButtonType.signIn,
                  //     onPressed: () => _signInWithApple(context),
                  //   ),
                ],
              ),
            ],
          ),
          Center(
            child: authProvider.status == Status.authenticating
                ? const CircularProgressIndicator(
              color: AppColors.lightGrey,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      persistentFooterButtons: [

        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactPage()));
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  // color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Don't have a school code. Contact Us!",
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          color: Colors.blue,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationColor: Colors.blue,
                        ),),
                    ),
                  ),
                )
            ),
          ],
        ),


      ],
    );
  }

}
