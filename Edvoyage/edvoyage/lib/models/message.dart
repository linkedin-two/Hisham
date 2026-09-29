class Message {
  final int? id;
  final String text;
  final bool isMe;
  final String? time;
  final String? sender;
  final bool delivered;
  final bool seen;

  const Message({
    this.id,
    required this.text,
    required this.isMe,
    this.time,
    this.sender,
    this.delivered = false,
    this.seen = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, bool isMe) {
    String? timeStr;
    if (json['timestamp'] != null) {
      final dt = DateTime.tryParse(json['timestamp']);
      if (dt != null) {
        timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Message(
      id: json['id'],
      text: json['text'] ?? '',
      isMe: isMe,
      time: timeStr,
      sender: json['sender'],
      delivered: json['delivered'] ?? false,
      seen: json['seen'] ?? false,
    );
  }
}
