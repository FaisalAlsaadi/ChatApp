import 'package:chatapp/models/message.dart';
import 'package:chatapp/services/encryption_service.dart';
import 'package:chatapp/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Get a stream of all users in the database
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Send an encrypted message to another user
  Future<void> sendMessage(
    String receiverID,
    String message, {
    bool isSafeSpace = false,
  }) async {
    try {
      final currentUserID = _auth.currentUser!.uid;
      final currentUserEmail = _auth.currentUser!.email!;
      final timestamp = Timestamp.now();

      print("[send] Sending message from $currentUserID to $receiverID");
      
      // Encrypt the message
      final encryptedMessage = E2EEncryptionService.encryptMessage(
        message,
        receiverID,
      );

      if (encryptedMessage == null) {
        throw Exception('Failed to encrypt message');
      }

      // Create a message object
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: encryptedMessage,
        timestamp: timestamp,
        isSafeSpace: isSafeSpace,
      );

      // Generate a unique chat room ID
      String chatRoomID = getChatRoomID(currentUserID, receiverID);
      
      print("[send] Storing message in chat room: $chatRoomID");

      // Save the message to Firestore
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());

      // Send a notification
      await _notificationService.sendMessageNotification(
        receiverID: receiverID,
        message: message,  // Original message for notification
        senderEmail: currentUserEmail,
      );
      
      print("[send] Message successfully sent and stored");
    } catch (e) {
      print("[send] Error sending message: $e");
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get a stream of messages between the current user and another user
  Stream<QuerySnapshot> getMessages(
    String userID,
    String otherUserID,
  ) {
    String chatRoomID = getChatRoomID(userID, otherUserID);
    
    print("[get] Getting messages from chat room: $chatRoomID");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Toggle an emoji reaction on a message
  Future<void> toggleReaction(
    String messageID,
    String chatRoomID,
    String emoji,
  ) async {
    final currentUserID = _auth.currentUser!.uid;
    final messageRef = _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID);

    final messageSnapshot = await messageRef.get();
    final messageData = messageSnapshot.data() as Map<String, dynamic>?;
    if (messageData == null) return;

    Message message = Message.fromMap(messageData);
    Map<String, List<String>> updatedReactions = {
      ...message.reactions,
    };

    if (updatedReactions.containsKey(emoji)) {
      List<String> users = [
        ...updatedReactions[emoji] ?? [],
      ];
      if (users.contains(currentUserID)) {
        users.remove(currentUserID);
        if (users.isEmpty) {
          updatedReactions.remove(emoji);
        } else {
          updatedReactions[emoji] = users;
        }
      } else {
        users.add(currentUserID);
        updatedReactions[emoji] = users;
      }
    } else {
      updatedReactions[emoji] = [currentUserID];
    }

    await messageRef.update({
      'reactions': updatedReactions,
    });

    if (message.senderID != currentUserID) {
      await _notificationService.sendMessageNotification(
        receiverID: message.senderID,
        message: "Reacted with $emoji to your message",
        senderEmail: _auth.currentUser!.email!,
      );
    }
  }

  /// Toggle the SafeSpace status of a message
  Future<void> toggleSafeSpace(
    String messageID,
    String chatRoomID,
  ) async {
    final messageRef = _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID);

    final messageSnapshot = await messageRef.get();
    final messageData = messageSnapshot.data() as Map<String, dynamic>?;
    if (messageData == null) return;

    Message message = Message.fromMap(messageData);
    await messageRef.update({
      'isSafeSpace': !message.isSafeSpace,
    });
  }

  /// Mark a message as viewed
  Future<void> markMessageAsViewed(
    String messageID,
    String chatRoomID,
  ) async {
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID)
        .update({'hasBeenViewed': true});
  }

  /// Delete all SafeSpace messages that have been viewed
  Future<void> deleteViewedSafeSpaceMessages(
    String chatRoomID,
  ) async {
    final messagesSnapshot =
        await _firestore
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .where('isSafeSpace', isEqualTo: true)
            .where('hasBeenViewed', isEqualTo: true)
            .get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get a consistent chat room ID for two users
  String getChatRoomID(String userID1, String userID2) {
    List<String> ids = [userID1, userID2];
    ids.sort();
    return ids.join("_");
  }
}