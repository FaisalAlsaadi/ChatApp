import 'package:chatapp/chat_services/chat_services.dart';
import 'package:chatapp/components/chat_bubble.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });
  final String receiverEmail;
  final String receiverID;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controllers
  final TextEditingController _messageController =
      TextEditingController();

  // chat and auth services
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        //cause a delay so keyboard shows up
        // then the amount of remaining space will be calculated
        // then auto scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    //wait for listview to be built then autoscroll down
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController =
      ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async {
    // if textfield isn't empty
    if (_messageController.text.isNotEmpty) {
      //send message
      await _chatServices.sendMessage(
        widget.receiverID,
        _messageController.text,
      );

      //clear text controller
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          //display all messages
          Expanded(child: _buildMessageList()),

          //display user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(
        widget.receiverID,
        senderID,
      ),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Text("Loading");
        }
        // return listview

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs
                  .map((doc) => _buildMessageItem(doc))
                  .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser =
        data['senderID'] ==
        _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser
            ? Alignment.centerRight
            : Alignment.centerLeft;

    //align message to the right if sender/ receiver left

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  // msg input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          //textfield should take most of the space
          Expanded(
            child: MyTextfield(
              hintText: "Type a message",
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),

          //send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
