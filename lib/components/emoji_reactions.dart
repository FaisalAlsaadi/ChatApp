import 'package:flutter/material.dart';

class EmojiReactions extends StatelessWidget {
  const EmojiReactions({
    super.key,
    required this.reactions,
    required this.currentUserID,
    required this.messageID,
    required this.onReactionTapped,
  });

  final Map<String, List<String>> reactions;
  final String currentUserID;
  final String messageID;
  final Function(String emoji) onReactionTapped;

  // Common emoji options
  static const List<String> commonEmojis = ['❤️', '👍', '👎', '😂', '😮', '😢'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display existing reactions if any
        if (reactions.isNotEmpty) _buildExistingReactions(context),
        
        // Add reaction button
        GestureDetector(
          onTap: () => _showReactionPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('+ Add reaction', 
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingReactions(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: reactions.entries.map((entry) {
        final emoji = entry.key;
        final userIDs = entry.value;
        final bool hasReacted = userIDs.contains(currentUserID);
        
        return GestureDetector(
          onTap: () => onReactionTapped(emoji),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: hasReacted 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: hasReacted 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
                : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 2),
                Text(
                  userIDs.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add reaction',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: commonEmojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      onReactionTapped(emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}