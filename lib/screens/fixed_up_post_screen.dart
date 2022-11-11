import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_firebase_signin/providers/user_provider.dart';
import 'package:google_firebase_signin/resources/firestore_methods.dart';
import 'package:google_firebase_signin/utilities/colors.dart';
import 'package:google_firebase_signin/utilities/utils.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class FixedUpPost extends StatefulWidget {
  const FixedUpPost({Key? key}) : super(key: key);

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
        );
      } else {
        res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          _titleController.text,
          username,
          profImage,
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
          title: const Text('Choose a photo'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
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
      content: Text("Posts need atleast both a title and description."),
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
    //
    // _file == null
    //     ? Center(
    //   child: IconButton(
    //     icon: const Icon(
    //       Icons.upload,
    //     ),
    //     onPressed: () => _selectImage(context),
    //   ),
    // )
    //
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white24,
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add a Post',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: <Widget>[
          // TextButton(
          //   onPressed: () =>
          //       postImage(
          //         // photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
          //
          //         profileProvider.getPrefs(FirestoreConstants.id) ?? "",
          //         profileProvider.getPrefs(FirestoreConstants.displayName) ??
          //             "",
          //         profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "",
          //       ),
          //   // child: const Text(
          //   //   "Post",
          //   //   style: TextStyle(
          //   //       color: Colors.blueAccent,
          //   //       fontWeight: FontWeight.bold,
          //   //       fontSize: 16.0),
          //   // ),
          // )
        ],
      ),
      // POST FORM
      body: SingleChildScrollView(

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
                // Text()
                // TextFormField(
                //   controller: _descriptionController//     filled: true, //<-- SEE HERE
                //     fillColor: Colors.deepPurpleAccent, //<-- SEE HERE
                //     border: UnderlineInputBorder(),
                //     labelText: 'Enter your username',
                //   ),
                // ),
                // CircleAvatar(
                //   backgroundImage: NetworkImage(
                //     profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "",
                //   ),
                // ),
                Padding(padding: EdgeInsets.fromLTRB(8, 12, 8, 5),
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,

                    child: Text("Title",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                    child: Text('Upload Post'),
                    onPressed: () {
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
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

//#eceded