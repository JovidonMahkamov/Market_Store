import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_message_worker.dart';

class ChatBubbleWorkerWidget extends StatelessWidget {
  final ChatMessageWorker message;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final void Function(Offset position, bool isMe) onShowMenu;
  final void Function(Offset position, bool isMe) onTapMenu;
  final VoidCallback onEnterSelectionMode;
  final VoidCallback onToggleSelect;

  const ChatBubbleWorkerWidget({
    super.key,
    required this.message,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onDelete,
    required this.onEdit,
    required this.onCopy,
    required this.onShowMenu,
    required this.onTapMenu,
    required this.onEnterSelectionMode,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPressStart: (details) {
              onEnterSelectionMode();
            },
            onTapUp: (details) {
              if (isSelectionMode) {
                onToggleSelect();
              } else {
                onTapMenu(details.globalPosition, isMe);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purple.withOpacity(0.5)
                    : isMe
                    ? const Color(0xff9859EF)
                    : const Color(0xFFF7F2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}