import 'package:chatapp/chat_services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/encryption_service.dart';
import 'package:chatapp/components/chat_bubble.dart';
import 'package:chatapp/components/my_textfield.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _chatServices = ChatServices();
  final _authService = AuthService();
  late final String _chatRoomID;
  final _viewedSafeMessages = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final currentUser = _authService.getCurrentUser();
    _chatRoomID = _chatServices.getChatRoomID(
      currentUser!.uid,
      widget.receiverID,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          _scrollToBottom,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _processSafeMessages();
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _processSafeMessages();
    }
  }

  Future<void> _processSafeMessages() async {
    for (final msgId in _viewedSafeMessages) {
      await _chatServices.markMessageAsViewed(
        msgId,
        _chatRoomID,
      );
    }
    _viewedSafeMessages.clear();
    await _chatServices.deleteViewedSafeSpaceMessages(
      _chatRoomID,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatServices.sendMessage(
        widget.receiverID,
        text,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _toggleReaction(
    String emoji,
    String messageID,
  ) async {
    await _chatServices.toggleReaction(
      messageID,
      _chatRoomID,
      emoji,
    );
  }

  Future<void> _toggleSafeSpace(String messageID) async {
    await _chatServices.toggleSafeSpace(
      messageID,
      _chatRoomID,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserID = _authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatServices.getMessages(
                currentUserID,
                widget.receiverID,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading messages'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, i) => _buildMessageItem(
                    snapshot.data!.docs[i],
                    currentUserID,
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    DocumentSnapshot doc,
    String currentUserID,
  ) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final messageID = doc.id;
      final senderID = data['senderID'] as String;
      final isCurrentUser = senderID == currentUserID;
      final isSafeSpace = data['isSafeSpace'] as bool? ?? false;

      if (isSafeSpace && !isCurrentUser) {
        _viewedSafeMessages.add(messageID);
      }

      final rawReactions = data['reactions'] as Map<String, dynamic>?;
      final reactions = rawReactions?.map(
        (emoji, users) => MapEntry(
          emoji,
          List<String>.from(users as List<dynamic>),
        ),
      ) ?? {};

      // Decrypt the message
      String message;
      try {
        final encryptedMessage = data['message'] as String;
        
        // Pass the sender ID for proper decryption
        final decryptedMessage = E2EEncryptionService.decryptMessage(
          encryptedMessage,
          senderID,
        );
        
        message = decryptedMessage ?? '[Could not decrypt message]';
        
      } catch (e) {
        print('[ChatPage] Error decrypting message: $e');
        message = '[Error: unable to decrypt message]';
      }

      return Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ChatBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          messageID: messageID,
          reactions: reactions,
          onReactionTapped: _toggleReaction,
          onToggleSafeSpace: _toggleSafeSpace,
          isSafeSpace: isSafeSpace,
          currentUserID: currentUserID,
        ),
      );
    } catch (e) {
      print('[ChatPage] Error building message item: $e');
      return Text('Error displaying message: $e');
    }
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: MyTextfield(
                hintText: 'Type a message',
                controller: _messageController,
                focusNode: _focusNode,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}