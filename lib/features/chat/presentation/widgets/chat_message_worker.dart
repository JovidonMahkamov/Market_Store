/// Xabar modeli — location xabari uchun qo'shimcha maydonlar
class ChatMessageWorker {
  final String id;
  String text;
  final DateTime createdAt;
  final bool isMe;

  // Lokatsiya uchun qo'shimcha maydonlar
  final double? latitude;
  final double? longitude;

  ChatMessageWorker({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isMe,
    this.latitude,
    this.longitude,
  });

  /// Bu xabar lokatsiya xabarimi?
  bool get isLocation => latitude != null && longitude != null;

  /// Bu xabar mahsulot kartochkasimi?
  bool get isProductCard => text == 'product_card';
}