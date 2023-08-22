import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_firebase_signin/providers/user_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:sentiment_dart/sentiment_dart.dart';

import '../providers/profile_provider.dart';


/**
 * page displays uploading page for users to post service hour opporutnity
 */

class FixedUpPost extends StatefulWidget {

  final String schoolName;
  // final bool isAdmin;
  const FixedUpPost({
    Key? key,
    required this.schoolName,
  }) : super(key: key);

  // const FixedUpPost({Key? key}) : super(key: key);

  @override
  _FixedUpPostState createState() => _FixedUpPostState();
}
class _FixedUpPostState extends State<FixedUpPost> {
  Uint8List? _file;
  bool isLoading = false;
  late ProfileProvider profileProvider;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  /**
   * postsImage for uploading posts
   * @param uid
   * @param username
   * @param profImage
   */
  void postImage(String uid, String username, String profImage) async {


    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res;
      if (_file == null) {
        res = await FireStoreMethods().uploadPost_withoutPhoto(
          _descriptionController.text,
          uid,
          _titleController.text,
          username,
          profImage,
          widget.schoolName,
        );
      } else {
        res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          _titleController.text,
          username,
          profImage,
          widget.schoolName,
        );
      }
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose a photo', style: TextStyle(fontFamily: 'Gilroy'),),
          children: <Widget>[
            // SimpleDialogOption(
            //     padding: const EdgeInsets.all(20),
            //     child: const Text('Take a photo'),
            //     onPressed: () async {
            //       Navigator.pop(context);
            //       Uint8List file = await pickImage(ImageSource.camera);
            //       setState(() {
            //         _file = file;
            //       });
            //     }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Gilroy'),),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'Gilroy'),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  showProfanityAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(fontFamily: 'Gilroy'),),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Can't Post!", style: TextStyle(fontFamily: 'Gilroy'),),
      content: Text("Posts are not allowed to contain any profanity or mean messages. Please fix your post in order to adhere to the required guidelines.", style: TextStyle(fontFamily: 'Gilroy'),),
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

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(fontFamily: 'Gilroy'),),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Not Finished!", style: TextStyle(fontFamily: 'Gilroy'),),
      content: Text("Posts need atleast both a title and description.", style: TextStyle(fontFamily: 'Gilroy'),),
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
    late ProfileProvider profileProvider = context.read<ProfileProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Set the height of the line
            child: Container(
              color: AppColors.greyColor, // Set the color of the line
              height: 1.0, // Set the height of the line
            ),
          ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black,)),
        title: const Text(
            'Create a Post',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.spaceLight,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w200,
              fontSize: Sizes.dimen_24,
            ),
          ),
      ),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: AppColors.spaceCadet,
      //   leading: IconButton(
      //       onPressed: () => Navigator.pop(context),
      //       icon: const Icon(Icons.arrow_back)), //
      //   title: const Text(
      //     'Add a Post',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   centerTitle: false,
      //   actions: <Widget>[
      //   ],
      // ),
      // // POST FORM
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              isLoading
                  ? const LinearProgressIndicator()
                  : const Padding(padding: EdgeInsets.only(top: 0.0)),
              const Divider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(8, 12, 8, 5),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: Text("Title",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Gilroy'),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                            hintText: "Enter title...",
                            border: UnderlineInputBorder()),
                        maxLines: 1,
                        style: TextStyle(fontFamily: 'Gilroy'),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 12, 8, 5),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Gilroy'),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Enter description...",
                            border: UnderlineInputBorder()),
                        maxLines: null,
                        style: TextStyle(fontFamily: 'Gilroy'),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 20, 8, 12),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: Text("Image (Optional)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Gilroy'),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 10, 8, 12),
                    child: SizedBox(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: _file == null
                        ? InkWell(
                          child: Container(
                          color: Colors.indigo
                        ),
                      onTap: () {
                       _selectImage(context);
                      },
                      ) : Container(
                        decoration: BoxDecoration(
                        image: DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: MemoryImage(_file!),
                        )),
                      ) ,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                        primary: AppColors.spaceCadet,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text('Upload Post', style: TextStyle(fontFamily: 'Gilroy'),),
                      onPressed: () {
                        final filter = ProfanityFilter();
                        String content =  _descriptionController.text;
                        content = content.toLowerCase();
                        List<String> allWords = filter.wordsToFilterOutList;
                        bool hasProfanity = false;

                        print(Sentiment.analysis(content));
                        SentimentResult holdSentimentAnalysis = Sentiment.analysis(content);
                        if (holdSentimentAnalysis.score < 0) {
                          hasProfanity = true;
                        }

                        for (int i =0; i< allWords.length; i++) {
                          if (content.contains(allWords[i])) {
                            hasProfanity = true; break;
                          }
                        }
                        if (hasProfanity) {
                          showProfanityAlertDialog(context);
                        } else {
                          String description = _descriptionController.text;
                          String title = _titleController.text;
                          if (description.length > 0 && title.length > 0) {
                            postImage(
                              profileProvider.getPrefs(FirestoreConstants.id) ?? "",
                              profileProvider.getPrefs(FirestoreConstants.displayName) ?? "",
                              profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "",
                            );
                          } else {
                            showAlertDialog(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

//#eceded