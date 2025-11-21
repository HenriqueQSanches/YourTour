class Post {
  final int? postId;
  final int userId;
  final String caption;
  final String imagePath;
  final String location;
  final String timestamp;
  final int likes;

  Post({
    this.postId,
    required this.userId,
    required this.caption,
    required this.imagePath,
    required this.location,
    required this.timestamp,
    this.likes = 0,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'],
      userId: map['userId'],
      caption: map['caption'] ?? '',
      imagePath: map['imagePath'] ?? '',
      location: map['location'] ?? '',
      timestamp: map['timestamp'] ?? '',
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'caption': caption,
      'imagePath': imagePath,
      'location': location,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
