class Message {
  final int id;
  final int senderId;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      content: json['content'],
      timestamp: json['created_at'], 
    );
  }
}
