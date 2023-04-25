import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/screens/AdminFeed.dart';
import 'package:google_firebase_signin/screens/BadMessagesPage.dart';
import 'package:google_firebase_signin/screens/alltutors.dart';
import 'package:google_firebase_signin/screens/feed_screen.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/home_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/upload_post.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'chips.dart';


/**
 * bottom bar used for navigation between homepage and the service opportunities page
 * For administrator
 */

class bottomBarScreenAdmin extends StatefulWidget {
  final String schoolName;
  const bottomBarScreenAdmin({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  @override
  _bottomBarScreenAdminState createState() => _bottomBarScreenAdminState();
}

class _bottomBarScreenAdminState extends State<bottomBarScreenAdmin> {
  int selectedPage = 0;
  final _pageOptions = [];

  @override
  void initState()  {
    super.initState();
    _pageOptions.add(BadMessagesScreen(schoolName: widget.schoolName));
    _pageOptions.add(AdminFeedScreen(schoolName: widget.schoolName));
  }

  // final _pageOptions = [
  //   BadMessagesScreen(),
  //   AdminFeedScreen(),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 30), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.add_to_photos_outlined, size: 30), label: "Posts"),
          ],
          selectedItemColor: const Color(0xFF141848),
          elevation: 0.0,
          unselectedItemColor: Colors.indigo,
          currentIndex: selectedPage,
          backgroundColor: Colors.white54,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}