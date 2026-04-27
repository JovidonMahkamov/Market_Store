import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chat_message_worker.dart';

class ChatBubbleWorkerWidget extends StatelessWidget {
  final ChatMessageWorker message;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ChatBubbleWorkerWidget({
    super.key,
    required this.message,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(

                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 30),
                constraints: const BoxConstraints(maxWidth: 260),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                    isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                    isMe ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16.sp
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  right: 0,
                  top: 1,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Tahrirlash',style: TextStyle(color:Colors.blueAccent),),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('O‘chirish',style: TextStyle(color: Colors.red),),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          )
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
