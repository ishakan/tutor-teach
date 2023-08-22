import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/app_constants.dart';
import 'package:google_firebase_signin/models/post.dart';
import 'package:google_firebase_signin/screens/alltutors.dart';
import 'package:google_firebase_signin/screens/goToTutors.dart';
import 'package:google_firebase_signin/screens/upload_post.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/loading_view.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/providers/home_provider.dart';
import 'package:google_firebase_signin/screens/chat_page.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:google_firebase_signin/screens/profile_page.dart';
import 'package:google_firebase_signin/utilities/debouncer.dart';
import 'package:google_firebase_signin/utilities/keyboard_utils.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'chips.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

final controllerEmail = TextEditingController();
final controllerName = TextEditingController();
final controllerSubject = TextEditingController();
final controllerMessage = TextEditingController();

/**
 * sends email third party provider, EmailJs
 */

Future sendEmail() async {
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  const serviceId = "service_qf521vb";
  const templateId = "template_p4bxabc";
  const userId = "D7lCesPLQCSKfNiiv";
  final response = await http.post(url,
  headers: {'origin' : 'http://localhost', 'Content-Type' : 'application/json'},
    body: json.encode({
      "service_id": serviceId,
      "template_id" : templateId,
      "user_id" : userId,
      "template_params" : {
        "name" : controllerName.text,
        "subject" : controllerSubject.text,
        "message" : controllerMessage.text,
        "user_email" : controllerEmail.text,
      }
    })
  );
  return response.statusCode;
}

/**
 * page allows anone to contact our email
 */

class _ContactPageState extends State<ContactPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: AppColors.indyBlue,
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back)), //
      title: const Text(
        'Contact Page',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    ),
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text("Contact Page"),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            text(directions: "Feel free to contact us! Fill out the boxes below with the information about the reason for contacting. Messages will recieve a response within 72 hours."),
            buildTextFild(title: "Email", controller: controllerEmail),
            buildTextFild(title: "Name", controller: controllerName),
            buildTextFild(title: "Subject", controller: controllerSubject),
            buildMessageField(title: "Message", controller: controllerMessage),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.indyBlue,
                minimumSize: Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 20),
                elevation: 0,
              ),
              onPressed: () => sendEmail(),
              child: Text("Send Message"),
            )

          ],
        )
      ),
  );

  // Future sendEmail({
  //   required String name,
  //   required String email,
  //   required String subject,
  //   required String message,
  // }) async {
  //   final serviceId = "service_qf521vb";
  //   final templateId = "template_p4bxabc";
  //   final userId = "";
  //
  //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  //   final response = await http.post(
  //       url,
  //       body: {
  //         'service_id' : serviceId,
  //         'template_id' : templateId,
  //         'user_id' : userId,
  //       }
  //   );
  // }

  Widget text({
    required String directions,
    int maxLines = 1,}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            directions,
            style: TextStyle(fontSize: 15, color: Color(0xff8B8B8B)),
          ),
          const SizedBox(height: 20,),
        ],
      );

  Widget buildTextFild({
    required String title,
    required TextEditingController controller,
    int maxLines = 1,}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4,),
          TextField(
            maxLines: maxLines,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,                      // Added this
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 15,),
        ],
      );

  Widget buildMessageField({
    required String title,
    required TextEditingController controller,
    int minLines = 5,}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4,),
          TextField(
            minLines: minLines,
            maxLines: 12,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,                      // Added this
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ],
      );
}
