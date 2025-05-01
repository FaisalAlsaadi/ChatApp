import 'package:flutter/material.dart';
import 'package:chatapp/components/emoji_reactions.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.reactions,
    required this.currentUserID,
    required this.onReactionTapped,
    required this.onToggleSafeSpace,
    required this.isSafeSpace,
  });

  final String message;
  final bool isCurrentUser;
  final String messageID;
  final Map<String, List<String>> reactions;
  final String currentUserID;
  final Function(String emoji, String messageID)
  onReactionTapped;
  final Function(String messageID) onToggleSafeSpace;
  final bool isSafeSpace;

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(
                isSafeSpace
                    ? Icons.security_update_warning
                    : Icons.security,
                color:
                    isSafeSpace
                        ? Colors.grey
                        : Colors.green,
              ),
              title: Text(
                isSafeSpace
                    ? 'Disable SafeSpace'
                    : 'Enable SafeSpace (self-erasing)',
              ),
              subtitle:
                  isSafeSpace
                      ? const Text(
                        'Message will be permanent',
                      )
                      : const Text(
                        'Message will erase after being viewed',
                      ),
              onTap: () {
                onToggleSafeSpace(messageID);
                Navigator.pop(context);
              },
            ),
            // Add more options here if needed
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress:
              isCurrentUser
                  ? () => _showOptionsMenu(context)
                  : null,
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSafeSpace
                      ? (isCurrentUser
                          ? Colors.purple
                          : Colors.purple.shade300)
                      : (isCurrentUser
                          ? Colors.green
                          : Colors.grey.shade500),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                if (isSafeSpace) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off,
                        size: 12,
                        color: Colors.white.withOpacity(
                          0.7,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SafeSpace',
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.7,
                          ),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // Emoji reactions
        Padding(
          padding: EdgeInsets.only(
            left: isCurrentUser ? 0 : 25,
            right: isCurrentUser ? 25 : 0,
          ),
          child: EmojiReactions(
            reactions: reactions,
            currentUserID: currentUserID,
            messageID: messageID,
            onReactionTapped:
                (emoji) =>
                    onReactionTapped(emoji, messageID),
          ),
        ),
      ],
    );
  }
}
