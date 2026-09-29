class Conversation {
  final int? id;
  final String otherEmail;
  final String otherName;
  final String lastText;
  final DateTime? lastTime;
  final int unread;
  final bool isNew;

  Conversation({
    this.id,
    required this.otherEmail,
    this.otherName = '',
    this.lastText = '',
    this.lastTime,
    this.unread = 0,
    this.isNew = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['conversation_id'],
      otherEmail: json['other_email'] ?? '',
      otherName: json['other_name'] ?? '',
      lastText: json['last_text'] ?? '',
      lastTime: json['last_time'] != null 
          ? DateTime.tryParse(json['last_time'])
          : null,
      unread: json['unread'] ?? 0,
      isNew: json['is_new'] ?? false,
    );
  }

  String get displayName => otherName.isNotEmpty ? otherName : otherEmail;
  
  String get initials {
    final name = displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
