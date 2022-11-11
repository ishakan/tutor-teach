import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen_admin.dart';
import 'package:google_firebase_signin/screens/contact_page.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _signUpKey = GlobalKey<FormState>();
  String isTutor = "";
  TextEditingController? isTutorController;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _conformPwd = TextEditingController();

  // final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
        Fluttertoast.showToast(msg: 'Sign in successful');
        break;
      default:
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              vertical50,
              const Text(
                'Welcome to TutorTeach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Sizes.dimen_26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              vertical30,
              const Text(
                'Login to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Sizes.dimen_22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              vertical50,
              Center(child: Image.asset('assets/images/back.png')),
              vertical50,
              const Text('Enter school code:', style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: AppColors.spaceCadet,
              ),),
              TextField(
                decoration: kTextInputDecoration.copyWith(
                    hintText: '######'),
                controller: isTutorController,
                // decoration: kTextInputDecoration.copyWith(
                //     hintText: 'Write about yourself...'),
                onChanged: (value) {
                  isTutor = value;
                },
              ),
              GestureDetector(
                onTap: () async {
                  if (isTutor != "AAAAAA") {
                    showAlertDialog(context);
                  } else {
                    // bool accepted = await authProvider.showAlertDialog(context);
                    // if (accepted) {
                      bool isSuccess = await authProvider.handleGoogleSignIn(context);
                      bool isAdmin = await authProvider.isAdminEmail();
                      if (isSuccess && isAdmin) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => bottomBarScreenAdmin()));
                      } else if (isSuccess) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => bottomBarScreen()));
                      }
                      // else {
                      //   // authProvider.status = Status.authenticateCanceled;
                      // }
                    // }
                  }
                },
                child: Image.asset('assets/images/google_login.jpg'),
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
                  alignment: Alignment.bottomCenter,
                  child: Text("Don't have a school code. Contact Us!",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.wavy,
                      decorationColor: Colors.blue,

                    ),),
                ),
              ),
            )
        ),
          // InkWell(
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          //     child: Align(
          //       alignment: Alignment.bottomCenter,
          //       child: Text("Don't have a school code. Contact Us!",
          //         style: TextStyle(
          //           color: Colors.blue,
          //           fontSize: 15,
          //           decoration: TextDecoration.underline,
          //           decorationStyle: TextDecorationStyle.wavy,
          //           decorationColor: Colors.blue,
          //
          //         ),),
          //     ),
          //   ),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => const ContactPage()));
          //   },
          // )
        ],
      ),
    );
  }

  //
  // Widget signUpAuthButton(BuildContext context, String buttonName) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //           minimumSize: Size(MediaQuery.of(context).size.width - 60, 30.0),
  //           elevation: 5.0,
  //           primary: Color.fromRGBO(57, 60, 80, 1),
  //           padding: EdgeInsets.only(
  //             left: 20.0,
  //             right: 20.0,
  //             top: 7.0,
  //             bottom: 7.0,
  //           ),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //           )),
  //       child: Text(
  //         buttonName,
  //         style: TextStyle(
  //           fontSize: 25.0,
  //           letterSpacing: 1.0,
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       onPressed: () async {
  //         if (this._signUpKey.currentState!.validate()) {
  //           print('Validated');
  //
  //           if (mounted) {
  //             setState(() {
  //               this._isLoading = true;
  //             });
  //           }
  //
  //           SystemChannels.textInput.invokeMethod('TextInput.hide');
  //
  //           final EmailSignUpResults response = await this
  //               ._emailAndPasswordAuth
  //               .signUpAuth(email: this._email.text, pwd: this._pwd.text);
  //           if (response == EmailSignUpResults.SignUpCompleted) {
  //             Navigator.push(
  //                 context, MaterialPageRoute(builder: (_) => TakePrimaryUserData()));
  //           } else {
  //             final String msg =
  //             response == EmailSignUpResults.EmailAlreadyPresent
  //                 ? 'Email Already Present'
  //                 : 'Sign Up Not Completed';
  //             ScaffoldMessenger.of(context)
  //                 .showSnackBar(SnackBar(content: Text(msg)));
  //           }
  //         } else {
  //           print('Not Validated');
  //         }
  //
  //         if (mounted) {
  //           setState(() {
  //             this._isLoading = false;
  //           });
  //         }
  //       },
  //     ),
  //   );
  // }
}
