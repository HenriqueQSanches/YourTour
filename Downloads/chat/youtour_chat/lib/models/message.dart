class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String senderName;
  final String? avatarUrl;
  final MessageType type;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMe,
    required this.senderName,
    this.avatarUrl,
    this.type = MessageType.text,
  });

  String get timeString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDay == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

enum MessageType {
  text,
  image,
  file,
}