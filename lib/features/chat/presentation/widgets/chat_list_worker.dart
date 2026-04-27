/// chatlar
class ChatListWorker {
  final String id;
  final String name;
  String lastMessage;
  String time;
  int unread;

  ChatListWorker({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}
