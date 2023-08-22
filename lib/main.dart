import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/screens/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_firebase_signin/firebase_options.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/providers/chat_provider.dart';
import 'package:google_firebase_signin/providers/home_provider.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_firebase_signin/screens/splash_page.dart';
import 'package:google_firebase_signin/utilities/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'google_firebase_signin',
      options: DefaultFirebaseOptions.currentPlatform

  );
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    prefs: prefs,
  ));
}

/**
 * connects main pages together
 */

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("first log message");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
                firebaseFirestore: firebaseFirestore,
                prefs: prefs,
                googleSignIn: GoogleSignIn(),
                firebaseAuth: FirebaseAuth.instance)),
        Provider<ProfileProvider>(
            create: (_) => ProfileProvider(
                prefs: prefs,
                firebaseFirestore: firebaseFirestore,
                firebaseStorage: firebaseStorage)),
        Provider<HomeProvider>(
            create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore)),
        Provider<ChatProvider>(
            create: (_) => ChatProvider(
                prefs: prefs,
                firebaseStorage: firebaseStorage,
                firebaseFirestore: firebaseFirestore))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EdiFLy',
        theme: appTheme,
        home: const SplashPage(),
      ),
    );
  }
}

// create student or tutor checkbox
// fix search bar
// allow tutors to show up
// allow users to view tutors profile



// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_firebase_signin/screens/home_page.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:google_firebase_signin/firebase_options.dart';
// // import 'package:google_firebase_signin/providers/auth_provider.dart';
// // import 'package:google_firebase_signin/providers/chat_provider.dart';
// // import 'package:google_firebase_signin/providers/home_provider.dart';
// // import 'package:google_firebase_signin/providers/profile_provider.dart';
// // import 'package:google_firebase_signin/screens/splash_page.dart';
// // import 'package:google_firebase_signin/utilities/theme.dart';
// // import 'package:flutter/foundation.dart';
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //       name: 'google_firebase_signin',
// //       options: DefaultFirebaseOptions.currentPlatform
// //
// //   );
// //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //   // final messaging = FirebaseMessaging.instance;
// //   //
// //   // final settings = await messaging.requestPermission(
// //   //   alert: true,
// //   //   announcement: false,
// //   //   badge: true,
// //   //   carPlay: false,
// //   //   criticalAlert: false,
// //   //   provisional: false,
// //   //   sound: true,
// //   // );
// //   //
// //   // if (kDebugMode) {
// //   //   print('Permission granted: ${settings.authorizationStatus}');
// //   // }
// //
// //   runApp(MyApp(
// //     prefs: prefs,
// //   ));
// // }
// //
// // /**
// //  * connects main pages together
// //  */
// //
// // class MyApp extends StatelessWidget {
// //   final SharedPreferences prefs;
// //   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
// //   final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
// //
// //   MyApp({Key? key, required this.prefs}) : super(key: key);
// //   @override
// //   Widget build(BuildContext context) {
// //     print("first log message");
// //     return MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider<AuthProvider>(
// //             create: (_) => AuthProvider(
// //                 firebaseFirestore: firebaseFirestore,
// //                 prefs: prefs,
// //                 googleSignIn: GoogleSignIn(),
// //                 firebaseAuth: FirebaseAuth.instance)),
// //         Provider<ProfileProvider>(
// //             create: (_) => ProfileProvider(
// //                 prefs: prefs,
// //                 firebaseFirestore: firebaseFirestore,
// //                 firebaseStorage: firebaseStorage)),
// //         Provider<HomeProvider>(
// //             create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore)),
// //         Provider<ChatProvider>(
// //             create: (_) => ChatProvider(
// //                 prefs: prefs,
// //                 firebaseStorage: firebaseStorage,
// //                 firebaseFirestore: firebaseFirestore))
// //       ],
// //       child: MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         title: 'EdiFLy',
// //         theme: appTheme,
// //         home: const SplashPage(),
// //       ),
// //     );
// //   }
// // }
//
// // create student or tutor checkbox
// // fix search bar
// // allow tutors to show up
// // allow users to view tutors profile
// //
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   runApp(MyApp(
//     prefs: prefs,
//   ));
// }
// // void main() => runApp(MyApp(prefs: prefs));
// //   MyApp({Key? key, required this.prefs}) : super(key: key);
// class MyApp extends StatelessWidget {
//
//   final SharedPreferences prefs;
//   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
//   final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
//
//   MyApp({Key? key, required this.prefs}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Your app name',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Your Title here'),
//         ),
//         body: Center(
//           child: Text('Hello World, of course'),
//         ),
//       ),
//     );
//   }
// }
//
// // File not found: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/libarclite_iphonesimulator.a
