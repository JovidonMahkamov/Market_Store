/// lib/features/chat/presentation/widgets/chat_message_worker.dart

enum MessageType { text, location, productCard, voice, voiceCircle, videoCircle }

class ChatMessageWorker {
  final String id;
  String text;
  final DateTime createdAt;
  final bool isMe;
  final MessageType type;

  final double? latitude;
  final double? longitude;

  final String? audioPath;
  final int? audioDuration;

  final String? videoPath;

  ChatMessageWorker({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isMe,
    this.type = MessageType.text,
    this.latitude,
    this.longitude,
    this.audioPath,
    this.audioDuration,
    this.videoPath,
  });

  bool get isLocation    => type == MessageType.location;
  bool get isProductCard => type == MessageType.productCard;
  bool get isVoice       => type == MessageType.voice;
  bool get isVoiceCircle => type == MessageType.voiceCircle;
  bool get isVideoCircle => type == MessageType.videoCircle;
}