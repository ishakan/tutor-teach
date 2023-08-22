import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/screens/alltutors.dart';
import 'package:google_firebase_signin/screens/feed_screen.dart';
import 'package:google_firebase_signin/screens/fixed_up_post_screen.dart';
import 'package:google_firebase_signin/screens/home_page.dart';
import 'package:google_firebase_signin/screens/home_page2.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/upload_post.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'chips.dart';

/**
 * bottom bar used for navigation between homepage and the service opportunities page
 * For regular user
 */

class bottomBarScreen extends StatefulWidget {
  final String schoolName;
  const bottomBarScreen({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  @override
  _bottomBarScreenState createState() => _bottomBarScreenState();
}

class _bottomBarScreenState extends State<bottomBarScreen> {
  int selectedPage = 0;
  final _pageOptions = [];

  @override
  void initState()  {
    super.initState();
    _pageOptions.add(HomePage2(schoolName: widget.schoolName));
    _pageOptions.add(FeedScreen(schoolName: widget.schoolName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pageOptions[selectedPage],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.greyColor,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 30),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_to_photos_outlined, size: 30),
              label: "Posts",
            ),
          ],
          selectedItemColor: const Color(0xFF141848),
          elevation: 0.0,
          unselectedItemColor: Colors.indigo,
          currentIndex: selectedPage,
          selectedLabelStyle: TextStyle(fontFamily: 'Gilroy', fontSize: 14),
          unselectedLabelStyle: TextStyle(fontFamily: 'Gilroy', fontSize: 14),
          backgroundColor: Colors.white54,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
        ),
      ),
    );
  }

}