import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final Map<String, List<String>> reactions;
  final bool isSafeSpace; // Flag for self-erasing messages
  final bool hasBeenViewed; // Track if message has been viewed

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.reactions = const {},
    this.isSafeSpace = false,
    this.hasBeenViewed = false,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'reactions': reactions,
      'isSafeSpace': isSafeSpace,
      'hasBeenViewed': hasBeenViewed,
    };
  }

  // Create a message from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    Map<String, List<String>> reactionsMap = {};
    
    if (map['reactions'] != null) {
      final rawReactions = map['reactions'] as Map<String, dynamic>;
      rawReactions.forEach((emoji, users) {
        if (users is List) {
          reactionsMap[emoji] = List<String>.from(users);
        }
      });
    }

    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      reactions: reactionsMap,
      isSafeSpace: map['isSafeSpace'] ?? false,
      hasBeenViewed: map['hasBeenViewed'] ?? false,
    );
  }

  // Create a copy of the message with updated properties
  Message copyWith({
    String? senderID,
    String? senderEmail,
    String? receiverID,
    String? message,
    Timestamp? timestamp,
    Map<String, List<String>>? reactions,
    bool? isSafeSpace,
    bool? hasBeenViewed,
  }) {
    return Message(
      senderID: senderID ?? this.senderID,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverID: receiverID ?? this.receiverID,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      isSafeSpace: isSafeSpace ?? this.isSafeSpace,
      hasBeenViewed: hasBeenViewed ?? this.hasBeenViewed,
    );
  }
}