import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/auth_service.dart';
import 'package:google_firebase_signin/models/pair.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/screens/admin/bottomBarScreen_admin.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as AppleButton;

// void main() {
//   runApp(MyApp());
// }

class FlutterEngineGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Three Page App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/second': (context) => SecondPage(),
        // '/third': (context) => ThirdPage(schoolName: schoolName),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: ListView(
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
            vertical30,
            // vertical30,
            Center(child: Image.asset('assets/images/back.png')),
            vertical20,
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
                style: OutlinedButton.styleFrom(
                  primary: Colors.redAccent, // Set text color to red accent
                  side: BorderSide(
                    color: Colors.redAccent,
                    width: 2.0,
                    style: BorderStyle.solid,
                  ), // Set outline color to red accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // Make edges more rounded
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Add more space between letters and borders
                  shadowColor: Colors.transparent, // Remove the button shadow
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.redAccent, // Set text color to red accent
                    fontSize: 20.0, // Set font size
                    fontFamily: 'Gilroy', // Set font family
                  ),
                ),
              ),
            ),
            vertical20,
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
                style: OutlinedButton.styleFrom(
                  primary: Colors.redAccent, // Set text color to red accent
                  side: BorderSide(
                    color: Colors.redAccent,
                    width: 2.0,
                    style: BorderStyle.solid,
                  ), // Set outline color to red accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // Make edges more rounded
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.0), // Add more space between letters and borders
                  shadowColor: Colors.transparent, // Remove the button shadow
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.redAccent, // Set text color to red accent
                    fontSize: 20.0, // Set font size
                    fontFamily: 'Gilroy', // Set font family
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Contact Us action
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Don't have a school code? Contact Us!",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: Colors.blue,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SecondPage extends StatefulWidget {

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late AlertDialog _alertDialog;
  final GlobalKey<FormState> _signUpKey = GlobalKey<FormState>();
  String isTutor = "", schoolName = "";
  TextEditingController? isTutorController;
  TextEditingController? schoolController;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _conformPwd = TextEditingController();

  // late AlertDialog _alertDialog;
  bool _isDialogShowing = false; // Track if the dialog is already showing


  @override
  void initState() {
    super.initState();
    _alertDialog = AlertDialog(
      title: Text("Wrong code"),
      content: Text("This school code does not exist"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
            });
          },
        ),
      ],
    );
  }

  void showAlertDialog(BuildContext context) {
    if (!_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(); // Close the dialog
              return true;
            },
            child: _alertDialog,
          );
        },
      ).then((_) {
        _isDialogShowing = false; // Reset the flag when the dialog is closed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child:
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  vertical: Sizes.dimen_30,
                  horizontal: Sizes.dimen_20,
                ),
                children: [
                  SizedBox(height: 40.0),
                  const Text(
                    'Enter School Information:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
                      fontSize: Sizes.dimen_26,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    child: GestureDetector(
                      onTap: () {},
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
                        onTap: () {},
                        onEditingComplete: () {},
                      ),
                    ),
                  ),
                  vertical30,
                  Container(
                    child: GestureDetector(
                      onTap: () {},
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
                        onTap: () {},
                        onEditingComplete: () {},
                      ),
                    ),
                  ),
                  vertical30,
                  Center(child: Image.asset('assets/images/second_img.png')),
                  vertical10,
                  // GestureDetector(
                  //   onTap: () async {

                  //   },
                  // ),
                  SizedBox(height: 40.0), // Added space for the bottom navigation
                ],
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // color: Colors.white, // Background color of the bottom navigation
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle "back" button press
                    },
                    child: Text(
                      '< Back',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Gilroy',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red, // First circle color (red)
                        ),
                      ),
                      SizedBox(width: 8.0), // Space between the circles
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey, // Second circle color (gray)
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      bool checkIfGood = false;
                      String hasToHave = "";
                      QuerySnapshot<Map<String, dynamic>> snapshot =
                      await FirebaseFirestore.instance.collection('schools').get();
                      for (int i = 0; i < snapshot.docs.length; i++) {
                        Map<String, dynamic> allData = snapshot.docs[i].data();
                        if (snapshot.docs[i].id == schoolName) {
                          hasToHave = allData["inEmail"];
                          if (allData["code"] == isTutor) {
                            checkIfGood = true;
                          } else {
                            break;
                          }
                        }
                      }

                      if (!checkIfGood) {
                        showSnackBar(
                          context,
                          'The school code does not exist.',
                        );
                        // showAlertDialog(context); // Show the AlertDialog
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThirdPage(schoolName: schoolName, hasToHave: hasToHave)));
                        // Navigator.pushNamed(context, '/third');
                      }
                      // Handle "next" button press
                    },
                    child: Text(
                      'Next >',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Gilroy',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    );
  }

}

class ThirdPage extends StatefulWidget {
  final String schoolName;
  final String hasToHave;
  const ThirdPage({
    Key? key,
    required this.schoolName,
    required this.hasToHave,
  }) : super(key: key);
  
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

Future<void> _signInWithApple(BuildContext context) async {
  try {
    print("RUNNNNN");
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithApple();
    print('uid: ${user.uid}');
  } catch (e) {
    // TODO: Show alert here
    print(e);
  }
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child:
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.dimen_30,
                horizontal: Sizes.dimen_20,
              ),
              children: [
                SizedBox(height: 15.0),
                const Text(
                  'Sign in with school email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.dimen_26,
                  ),
                ),
                SizedBox(height: 10.0),
                // vertical30,
                Center(child: Image.asset('assets/images/third_img.png')),
                SizedBox(height: 3.0),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // bool accepted = await authProvider.showAlertDialog(context);
                        // if (accepted) {
                        Pair isSuccess = await authProvider.handleGoogleSignIn(widget.schoolName, widget.hasToHave, context);

                        // bool isAdmin = await authProvider.isAdminEmail();
                        if (isSuccess.item1 == true && isSuccess.item2 == true) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => bottomBarScreenAdmin(schoolName: widget.schoolName,)));
                        } else if (isSuccess.item1 == true) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => bottomBarScreen(schoolName: widget.schoolName,)));
                        }
                        // else {
                        //   // authProvider.status = Status.authenticateCanceled;
                        // }
                        // }
                      },
                      child: Image.asset('assets/images/google_login4.png'),
                    ),
                    SizedBox(height: 5), // Add some spacing between the Google Sign-In image and Apple Sign-In button
                    AppleButton.AppleSignInButton(
                        style: AppleButton.ButtonStyle.black,
                        type: AppleButton.ButtonType.signIn,
                        onPressed: () => _signInWithApple(context),
                      // onPressed: appleLogIn,
                    )
                  ],
                ),
              ],
            ),
          ),
          // Column(
          //   children: [
          //     AppleButton.AppleSignInButton(
          //       style: AppleButton.ButtonStyle.black,
          //       type: AppleButton.ButtonType.signIn,
          //       onPressed: () async {
          //         AppleButton.AppleSignInButton(
          //           // style: ButtonStyle.black,
          //           type: AppleButton.ButtonType.signIn,
          //           onPressed: () => _signInWithApple(context),
          //         );
          //       }
          //       // onPressed: appleLogIn,
          //     )
          //     // if (appleSignInAvailable.isAvailable)
          //
          //   ],
          // ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // color: Colors.white, // Background color of the bottom navigation
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle "back" button press
                    },
                    child: Text(
                      '< Back',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Gilroy',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 17,
            child: Container(
              // color: Colors.white, // Background color of the bottom navigation
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey, // First circle color (red)
                    ),
                  ),
                  SizedBox(width: 8.0), // Space between the circles
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent, // Second circle color (gray)
                    ),
                  ),
                ],
              ),
            ),
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
    );
  }
}
