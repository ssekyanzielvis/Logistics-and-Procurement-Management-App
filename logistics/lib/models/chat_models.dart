enum MessageType { text, image, emoji }

class ChatUser {
  final String id; // Changed from UUID to String
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? profileImg;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImg,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'].toString(), // Ensure it's a string
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      profileImg: json['profile_img'],
      isOnline: json['is_online'] ?? false,
      lastSeen:
          json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_img': profileImg,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String? message;
  final String? imageUrl;
  final MessageType type;
  final bool isRead;
  final String? replyToId;
  final DateTime timestamp;
  final ChatUser? sender;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.imageUrl,
    this.type = MessageType.text,
    this.isRead = false,
    this.replyToId,
    required this.timestamp,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      chatRoomId: json['chat_room_id'].toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      message: json['message'],
      imageUrl: json['image_url'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['is_read'] ?? false,
      replyToId: json['reply_to_id']?.toString(),
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      sender: json['sender'] != null ? ChatUser.fromJson(json['sender']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'reply_to_id': replyToId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatRoom {
  final String id;
  final ChatUser otherUser;
  final ChatMessage? lastMessage;
  final DateTime? lastActivity;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.lastActivity,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'].toString(),
      otherUser: ChatUser.fromJson(json['other_user']),
      lastMessage:
          json['last_message'] != null
              ? ChatMessage.fromJson(json['last_message'])
              : null,
      lastActivity:
          json['last_activity'] != null
              ? DateTime.parse(json['last_activity'])
              : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user': otherUser.toJson(),
      'last_message': lastMessage?.toJson(),
      'last_activity': lastActivity?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}
