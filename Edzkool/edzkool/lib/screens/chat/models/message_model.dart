class Message {
  final int id;
  final String senderEmail;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool delivered;
  final bool seen;
  final bool isMe;

  Message({
    required this.id,
    required this.senderEmail,
    this.text = '',
    this.imageUrl,
    required this.timestamp,
    this.delivered = false,
    this.seen = false,
    this.isMe = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserEmail) {
    final sender = json['sender'] ?? '';
    return Message(
      id: json['id'] ?? 0,
      senderEmail: sender,
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      delivered: json['delivered'] ?? false,
      seen: json['seen'] ?? false,
      isMe: sender.toLowerCase() == currentUserEmail.toLowerCase(),
    );
  }

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
