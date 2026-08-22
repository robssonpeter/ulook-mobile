class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final int? bookingId;
  final String content;
  final String? readAt;
  final String createdAt;
  final String? senderName;
  final bool isMine;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.bookingId,
    required this.content,
    this.readAt,
    required this.createdAt,
    this.senderName,
    required this.isMine,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        senderId: json['sender_id'],
        receiverId: json['receiver_id'],
        bookingId: json['booking_id'],
        content: json['content'] ?? '',
        readAt: json['read_at'],
        createdAt: json['created_at'] ?? '',
        senderName: json['sender_name'],
        isMine: json['is_mine'] ?? false,
      );
}

class Conversation {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        otherUserId: json['other_user_id'],
        otherUserName: json['other_user_name'] ?? 'User',
        otherUserPhotoUrl: json['other_user_photo_url'],
        lastMessage: json['last_message'] ?? '',
        lastMessageAt: json['last_message_at'],
        unreadCount: json['unread_count'] ?? 0,
      );
}
