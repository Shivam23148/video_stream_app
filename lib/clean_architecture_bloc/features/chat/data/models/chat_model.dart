class ChatModel {
  final String id;
  final String message;
  final DateTime createdAt;

  ChatModel(this.id, this.message, this.createdAt);

  factory ChatModel.fromJson(Map<String, dynamic> data) {
    return ChatModel(data['id'], data['message'], data['createdAt']);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
