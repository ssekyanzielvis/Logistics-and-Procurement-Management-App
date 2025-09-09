import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/chat_models.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID as string
  String get currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  // Get all users for chat
  Future<List<ChatUser>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select(
            'id, full_name, email, phone, role, profile_image, is_active, is_online, last_seen',
          )
          .eq('is_active', true)
          .neq('id', currentUserId);

      return response.map((user) => ChatUser.fromJson(user)).toList();
    } catch (e) {
      print('Error loading users: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  // Get or create chat room
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      // Ensure user1_id is always the smaller ID for consistency
      final user1Id =
          currentUserId.compareTo(otherUserId) < 0
              ? currentUserId
              : otherUserId;
      final user2Id =
          currentUserId.compareTo(otherUserId) < 0
              ? otherUserId
              : currentUserId;

      // Check if chat room already exists
      final existingRoom =
          await _supabase
              .from('chat_rooms')
              .select('id')
              .eq('user1_id', user1Id)
              .eq('user2_id', user2Id)
              .maybeSingle();

      if (existingRoom != null) {
        return existingRoom['id'];
      }

      // Create new chat room
      final newRoom =
          await _supabase
              .from('chat_rooms')
              .insert({'user1_id': user1Id, 'user2_id': user2Id})
              .select('id')
              .single();

      return newRoom['id'];
    } catch (e) {
      print('Error creating chat room: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Get chat rooms for current user
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _supabase
          .from('chat_rooms')
          .select('''
            id,
            user1_id,
            user2_id,
            last_activity,
            last_message_id
          ''')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('last_activity', ascending: false);

      List<ChatRoom> chatRooms = [];

      for (var room in response) {
        final otherUserId =
            room['user1_id'] == currentUserId
                ? room['user2_id']
                : room['user1_id'];

        // Get other user details
        final otherUserResponse =
            await _supabase
                .from('users')
                .select(
                  'id, full_name, email, phone, role, profile_image, is_online, last_seen',
                )
                .eq('id', otherUserId)
                .single();

        final otherUser = ChatUser.fromJson(otherUserResponse);

        // Get unread count
        final unreadCount = await _getUnreadCount(room['id'], otherUserId);

        // Get last message if exists
        ChatMessage? lastMessage;
        if (room['last_message_id'] != null) {
          try {
            final lastMessageResponse =
                await _supabase
                    .from('messages')
                    .select('*')
                    .eq('id', room['last_message_id'])
                    .single();

            lastMessage = ChatMessage.fromJson(lastMessageResponse);
          } catch (e) {
            print('Error loading last message: $e');
          }
        }

        chatRooms.add(
          ChatRoom(
            id: room['id'],
            otherUser: otherUser,
            lastMessage: lastMessage,
            lastActivity:
                room['last_activity'] != null
                    ? DateTime.parse(room['last_activity'])
                    : null,
            unreadCount: unreadCount,
          ),
        );
      }

      return chatRooms;
    } catch (e) {
      print('Error loading chat rooms: $e');
      throw Exception('Failed to load chat rooms: $e');
    }
  }

  // Get unread message count
  Future<int> _getUnreadCount(String chatRoomId, String otherUserId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('chat_room_id', chatRoomId)
          .eq('sender_id', otherUserId)
          .eq('is_read', false)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Get messages stream
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('timestamp')
        .map(
          (data) =>
              data.map((message) => ChatMessage.fromJson(message)).toList(),
        );
  }

  // Send text message
  Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String message,
    String? replyToId,
  }) async {
    try {
      final response =
          await _supabase
              .from('messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': currentUserId,
                'receiver_id': receiverId,
                'message': message,
                'type': 'text',
                'reply_to_id': replyToId,
                'timestamp': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      // Update chat room last activity and last message
      await _supabase
          .from('chat_rooms')
          .update({
            'last_activity': DateTime.now().toIso8601String(),
            'last_message_id': response['id'],
          })
          .eq('id', chatRoomId);
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Send image message
  Future<void> sendImageMessage({
    required String chatRoomId,
    required String receiverId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      // Upload image to Supabase storage
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final imagePath = '$currentUserId/$fileName';

      await _supabase.storage.from('chat-attachments').upload(imagePath, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage
          .from('chat-attachments')
          .getPublicUrl(imagePath);

      // Send message with image
      final response =
          await _supabase
              .from('messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': currentUserId,
                'receiver_id': receiverId,
                'message': caption,
                'image_url': imageUrl,
                'type': 'image',
                'timestamp': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      // Update chat room last activity and last message
      await _supabase
          .from('chat_rooms')
          .update({
            'last_activity': DateTime.now().toIso8601String(),
            'last_message_id': response['id'],
          })
          .eq('id', chatRoomId);
    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Failed to send image: $e');
    }
  }

  // Pick image
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      throw Exception('Failed to pick image: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String senderId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_room_id', chatRoomId)
          .eq('sender_id', senderId)
          .eq('receiver_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('id', messageId)
          .eq('sender_id', currentUserId); // Only allow deleting own messages
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message: $e');
    }
  }

  // Clear chat
  Future<void> clearChat(String chatRoomId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('chat_room_id', chatRoomId)
          .eq('sender_id', currentUserId); // Only delete own messages
      await _supabase
          .from('chat_rooms')
          .update({'last_activity': null, 'last_message_id': null})
          .eq('id', chatRoomId);
    } catch (e) {
      print('Error clearing chat: $e');
      throw Exception('Failed to clear chat: $e');
    }
  }

  // Block user
  Future<void> blockUser(String userId) async {
    try {
      await _supabase.from('blocked_users').insert({
        'user_id': currentUserId,
        'blocked_user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error blocking user: $e');
      throw Exception('Failed to block user: $e');
    }
  }

  // Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _supabase
          .from('users')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUserId);
    } catch (e) {
      print('Failed to update online status: $e');
    }
  }

  // Send emoji message
  Future<void> sendEmojiMessage({
    required String chatRoomId,
    required String receiverId,
    required String emoji,
  }) async {
    try {
      final response =
          await _supabase
              .from('messages')
              .insert({
                'chat_room_id': chatRoomId,
                'sender_id': currentUserId,
                'receiver_id': receiverId,
                'message': emoji,
                'type': 'emoji',
                'timestamp': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      // Update chat room last activity and last message
      await _supabase
          .from('chat_rooms')
          .update({
            'last_activity': DateTime.now().toIso8601String(),
            'last_message_id': response['id'],
          })
          .eq('id', chatRoomId);
    } catch (e) {
      print('Error sending emoji: $e');
      throw Exception('Failed to send emoji: $e');
    }
  }

  // Get user by ID
  Future<ChatUser?> getUserById(String userId) async {
    try {
      final response =
          await _supabase
              .from('users')
              .select(
                'id, full_name, email, phone, role, profile_image, is_online, last_seen',
              )
              .eq('id', userId)
              .single();

      return ChatUser.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Search users
  Future<List<ChatUser>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('users')
          .select(
            'id, full_name, email, phone, role, profile_image, is_active, is_online, last_seen',
          )
          .eq('is_active', true)
          .neq('id', currentUserId)
          .or(
            'full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%',
          );

      return response.map((user) => ChatUser.fromJson(user)).toList();
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  // Get total unread count for all chats
  Future<int> getTotalUnreadCount() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('receiver_id', currentUserId)
          .eq('is_read', false)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error getting total unread count: $e');
      return 0;
    }
  }

  // Listen to real-time updates for unread count
  Stream<int> getUnreadCountStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map(
          (data) =>
              data
                  .where(
                    (message) =>
                        message['receiver_id'] == currentUserId &&
                        message['is_read'] == false,
                  )
                  .length,
        );
  }

  // Dispose method to clean up resources
  void dispose() {
    // Update offline status when disposing
    updateOnlineStatus(false);
  }
}
