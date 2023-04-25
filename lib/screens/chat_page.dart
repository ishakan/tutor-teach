import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_firebase_signin/models/push_notification.dart';
import 'package:google_firebase_signin/notification_service.dart';
import 'package:google_firebase_signin/screens/bottomBarScreen.dart';
import 'package:google_firebase_signin/screens/home_page2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';
import 'package:google_firebase_signin/allWidgets/common_widgets.dart';
import 'package:google_firebase_signin/models/chat_messages.dart';
import 'package:google_firebase_signin/providers/auth_provider.dart';
import 'package:google_firebase_signin/providers/chat_provider.dart';
import 'package:google_firebase_signin/providers/profile_provider.dart';
import 'package:google_firebase_signin/screens/login_page.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

/**
 * Page for all chat messages between regular students and student tutors
 */

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String userAvatar;
  final String schoolName;

  const ChatPage(
      {Key? key,
        required this.peerNickname,
        required this.peerAvatar,
        required this.peerId,
        required this.userAvatar,
        required this.schoolName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late int _totalNotifications;
  // late final FirebaseMessaging _messaging;
  PushNotification? _notificatinInfo;
  late String currentUserId;

  List<QueryDocumentSnapshot> listMessages = [];

  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = '';

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.instance.getInitialMessage();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChanged);
    scrollController.addListener(_scrollListener);
    readLocal();
    // requestPermission();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }
  /**
   * initializing base varibles
   */

  void readLocal() {
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }
    if (currentUserId.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId - ${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId} - $currentUserId';
    }
    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: widget.peerId});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadImageFile();
      }
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future<bool> onBackPressed() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
          currentUserId, {FirestoreConstants.chattingWith: null});
    }
    return Future.value(false);
  }


  void uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadImageFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, MessageType.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  /**
   * sendingMesage and updating FirebaseDatabase with message data
   */
  void onSendMessage(String content, int type) async {

    CollectionReference users = FirebaseFirestore.instance.collection('schools').doc(widget.schoolName).collection('users');
    DocumentReference userRef = users.doc(widget.peerId).collection('userMessaged').doc(currentUserId);
    print(userRef);

    print(widget.peerId);
    print(currentUserId);
    String dat2a = "state";
    String state = "";

    print(userRef.get());

    await userRef.get().then((DocumentSnapshot documentSnapshot) {
      print(documentSnapshot);
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        print(data);
        print("DAAA");
        state = data[dat2a].toString();
      }
    });
    print(state);
    print("THIS IS THE STATE PRINTING OUTT");

    if (state == "blocked") {
      Fluttertoast.showToast(
          msg: 'Unable to send a message. This user has you currently blocked.', backgroundColor: Colors.black);
    } else if (content.trim().isNotEmpty) {
      final filter = ProfanityFilter();
      String original = content;
      content = content.toLowerCase();
      List<String> allWords = filter.wordsToFilterOutList;
      String cleanString = content;
      bool hasProfanity = false;

      print(Sentiment.analysis(content));
      SentimentResult holdSentimentAnalysis = Sentiment.analysis(content);
      if (holdSentimentAnalysis.score < 0) {
        cleanString = "****";
        original = "****";
        hasProfanity = true;
      }

      for (int i =0; i< allWords.length; i++) {
        if (content.contains(allWords[i])) {
          cleanString = "****";
          original = "****";
          hasProfanity = true; break;
        }
      }
      String nonClean = content + "";
      content = cleanString;
      print(cleanString);
      print(nonClean);
      print("MESSAGE CONTENT");

      if (hasProfanity) {
        chatProvider.updateBadMessage(
            nonClean, type, currentUserId, widget.peerId, widget.schoolName);
      }

      textEditingController.clear();
      chatProvider.sendChatMessage(
          original, type, groupChatId, currentUserId, widget.peerId, widget.schoolName);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

      // String token = "";
      // LocalNotificationService.sendNotification(title: "New message", message: content, token: token);
      // LocalNotificationService
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  /**
   * checking if message was recieved
   */
  // checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.idFrom) ==
            currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * checking if message was sent
   */

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 &&
        listMessages[index - 1].get(FirestoreConstants.idFrom) !=
            currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _moveToScreen2(context);
            }),
        elevation: 0,
        centerTitle: true,
        title: Text('Chatting with ${widget.peerNickname}'.trim()),
        actions: [
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          // padding: const EdgeInsets.symmetric(horizontal: Sizes.dimen_8),
          child: Column(
            children: [
              buildListMessage(),
              buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  void _moveToScreen2(BuildContext context) =>
      Navigator.pop(context, true);
  // Navigator.pushReplacement(
  // context, MaterialPageRoute(builder: (context) => bottomBarScreen(schoolName: widget.schoolName,)));

  Widget buildMessageInput() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: getImage,
              icon: const Icon(
                Icons.camera_alt,
                size: Sizes.dimen_28,
              ),
              color: AppColors.white,
            ),
          ),
          Flexible(
              child: TextField(
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                decoration:
                kTextInputDecoration.copyWith(hintText: 'Message...'),
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, MessageType.text);
                },
              )),
          Container(
            margin: const EdgeInsets.only(left: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: () {
                onSendMessage(textEditingController.text, MessageType.text);
              },
              icon: const Icon(Icons.send_rounded),
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
      if (chatMessages.idFrom == currentUserId) {
        // right side (my message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatMessages.type == MessageType.text
                    ? messageBubble(
                  chatContent: chatMessages.content,
                  color: AppColors.lightBlue,
                  textColor: AppColors.white,
                  borderColor: AppColors.lightBlue,
                  margin: const EdgeInsets.only(right: Sizes.dimen_8, top: Sizes.dimen_1),
                )
                    : chatMessages.type == MessageType.image
                    ? Container(
                  margin: const EdgeInsets.only(
                      right: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: chatImage(
                      imageSrc: chatMessages.content, onTap: () {}),
                )
                    : const SizedBox.shrink(),
                isMessageSent(index)
                    ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  ),
                  child: Image.network(
                    widget.userAvatar,
                    width: Sizes.dimen_40,
                    height: Sizes.dimen_40,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.burgundy,
                          value: loadingProgress.expectedTotalBytes !=
                              null &&
                              loadingProgress.expectedTotalBytes !=
                                  null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(
                        Icons.account_circle,
                        size: 35,
                        color: AppColors.greyColor,
                      );
                    },
                  ),
                )
                    : Container(
                  width: 35,
                ),
              ],
            ),
            isMessageSent(index)
                ? Container(
              margin: const EdgeInsets.only(
                  right: Sizes.dimen_50,
                  top: Sizes.dimen_6,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isMessageReceived(index)
                // left side (received message)
                    ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.dimen_20),
                  ),
                  child: Image.network(
                    widget.peerAvatar,
                    width: Sizes.dimen_40,
                    height: Sizes.dimen_40,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.burgundy,
                          value: loadingProgress.expectedTotalBytes !=
                              null &&
                              loadingProgress.expectedTotalBytes !=
                                  null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(
                        Icons.account_circle,
                        size: 35,
                        color: AppColors.greyColor,
                      );
                    },
                  ),
                )
                    : Container(
                  width: 35,
                ),
                chatMessages.type == MessageType.text
                    ? messageBubble(
                  color: AppColors.white,
                  textColor: Colors.black,
                  borderColor: AppColors.greyColor,
                  chatContent: chatMessages.content,
                  margin: const EdgeInsets.only(left: Sizes.dimen_8, top: Sizes.dimen_1),
                )
                    : chatMessages.type == MessageType.image
                    ? Container(
                  margin: const EdgeInsets.only(
                      left: Sizes.dimen_10, top: Sizes.dimen_10),
                  child: chatImage(
                      imageSrc: chatMessages.content, onTap: () {}),
                )
                    : const SizedBox.shrink(),
              ],
            ),
            isMessageReceived(index)
                ? Container(
              margin: const EdgeInsets.only(
                  left: Sizes.dimen_50,
                  top: Sizes.dimen_6,
                  bottom: Sizes.dimen_8),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chatMessages.timestamp),
                  ),
                ),
                style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: Sizes.dimen_12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  /**
   * building list displaying all of the messages
   */
  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getChatMessage(groupChatId, _limit, widget.schoolName),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              listMessages = snapshot.data!.docs;
              if (listMessages.isNotEmpty) {
                return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: scrollController,
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]));
              } else {
                return const Center(
                  child: Text('No messages...'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.burgundy,
                ),
              );
            }
          })
          : const Center(
        child: CircularProgressIndicator(
          color: AppColors.burgundy,
        ),
      ),
    );
  }
}
