import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';

/// A reliable encryption service that ensures consistent key derivation
class E2EEncryptionService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Get the current user ID from Firebase Authentication
  static String get currentUserID => _auth.currentUser?.uid ?? '';

  /// Encrypt a message for a specific recipient
  static String? encryptMessage(String message, String recipientID) {
    try {
      print('[encrypt] Encrypting message for recipient: $recipientID');
      
      // Get encryption key - always use sender (current user) and recipient
      final senderID = currentUserID;
      final key = _deriveKey(senderID, recipientID);
      
      // Generate a random initialization vector
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // Create the encrypter with AES encryption
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      // Encrypt the message
      final encrypted = encrypter.encrypt(message, iv: iv);
      
      // Create an encryption package with all necessary data
      final encryptionData = {
        'senderID': senderID,        // Store sender ID
        'recipientID': recipientID,  // Store recipient ID
        'iv': iv.base64,             // Store IV in base64
        'ciphertext': encrypted.base64  // Store ciphertext in base64
      };
      
      print('[encrypt] Successfully encrypted message');
      return jsonEncode(encryptionData);
    } catch (e) {
      print('[encrypt] Encryption error: $e');
      return null;
    }
  }

  /// Decrypt a message
  static String? decryptMessage(String encryptedData, String senderID) {
    try {
      print('[decrypt] Decrypting message from sender: $senderID');
      
      // Parse the encryption package
      final data = jsonDecode(encryptedData);
      
      // Extract the necessary data
      final storedSenderID = data['senderID'] as String? ?? senderID;
      final recipientID = data['recipientID'] as String? ?? currentUserID;
      final ivString = data['iv'] as String;
      final ciphertextString = data['ciphertext'] as String;
      
      // Re-create the IV
      final iv = encrypt.IV.fromBase64(ivString);
      
      // Derive the key using the stored IDs rather than current auth state
      // For decryption, the current user is the recipient
      final key = _deriveKey(storedSenderID, recipientID);
      
      // Re-create the encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      // Convert ciphertext string back to encrypted object
      final ciphertext = encrypt.Encrypted.fromBase64(ciphertextString);
      
      // Decrypt the message
      final decrypted = encrypter.decrypt(ciphertext, iv: iv);
      
      print('[decrypt] Successfully decrypted message');
      return decrypted;
    } catch (e) {
      print('[decrypt] Decryption error: $e');
      return '[Could not decrypt message]';
    }
  }

  /// Generate a consistent encryption key based on the sender and recipient IDs
  static encrypt.Key _deriveKey(String senderID, String recipientID) {
    // Sort the IDs to ensure the same key regardless of who's sending and receiving
    final List<String> ids = [senderID, recipientID];
    ids.sort();
    
    // Create a unique, deterministic string from the sorted IDs
    final combinedIDs = '${ids[0]}_SECURE_CHAT_KEY_${ids[1]}';
    
    // Hash the combined string to create a secure key
    final keyBytes = sha256.convert(utf8.encode(combinedIDs)).bytes;
    
    // Create an encryption key from the hash
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }
}