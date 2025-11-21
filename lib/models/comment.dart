class Comment {
  final int? commentId;
  final int postId;
  final int userId;
  final String text;
  final String timestamp;

  Comment({
    this.commentId,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['commentId'],
      postId: map['postId'],
      userId: map['userId'],
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
