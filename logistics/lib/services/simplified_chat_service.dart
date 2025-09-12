// lib/services/simplified_chat_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';

/// A simplified chat service that doesn't rely on complex migrations
/// This is a fallback implementation if the main chat service fails
class SimplifiedChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get current user ID
  String get currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  // Check if a user is authenticated
  bool get isAuthenticated {
    return _supabase.auth.currentUser != null;
  }
  
  // Get all users for chat
  Future<List<ChatUser>> getAllUsers() async {
    try {
      // Try to get user data with columns we know exist
      final response = await _supabase
          .from('users')
          .select('id, full_name, email')
          .neq('id', currentUserId);
      
      // Convert to ChatUser objects with minimal data
      return response.map((json) {
        // Create a ChatUser with the available fields
        return ChatUser(
          id: json['id'],
          fullName: json['full_name'] ?? 'Unknown User',
          email: json['email'] ?? 'No Email',
          phone: json['phone'] ?? '',
          role: json['role'] ?? 'user',
          profileImg: json['profile_image'] ?? '',
          isOnline: false,
          lastSeen: null,
        );
      }).toList();
    } catch (e) {
      print('Error loading users: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  // Direct method to insert a chat room
  Future<String> createChatRoomDirectly(String otherUserId) async {
    try {
      // Insert directly with minimal fields
      final result = await _supabase.rpc('create_chat_room', params: {
        'current_user_id': currentUserId,
        'other_user_id': otherUserId,
      });
      
      return result;
    } catch (e) {
      print('Error creating chat room via RPC: $e');
      // Fallback to manual room creation logic
      return _manualCreateChatRoom(otherUserId);
    }
  }
  
  // Manual fallback for chat room creation
  Future<String> _manualCreateChatRoom(String otherUserId) async {
    try {
      final response = await _supabase
          .from('chat_rooms')
          .insert({
            'user1': currentUserId,  // Try alternative column names
            'user2': otherUserId,
          })
          .select('id')
          .single();
      
      return response['id'];
    } catch (e1) {
      try {
        // Try with user_id format
        final response = await _supabase
            .from('chat_rooms')
            .insert({
              'user_id_1': currentUserId,
              'user_id_2': otherUserId,
            })
            .select('id')
            .single();
        
        return response['id'];
      } catch (e2) {
        // As a last resort, try to get existing rooms and search manually
        try {
          final rooms = await _supabase.from('chat_rooms').select();
          for (var room in rooms) {
            // Check all possible column name combinations
            final possibleColumns = [
              ['user1_id', 'user2_id'],
              ['user1', 'user2'],
              ['user_id_1', 'user_id_2'],
              ['from_user_id', 'to_user_id']
            ];
            
            for (var cols in possibleColumns) {
              if (room[cols[0]] != null && room[cols[1]] != null) {
                if ((room[cols[0]] == currentUserId && room[cols[1]] == otherUserId) || 
                    (room[cols[0]] == otherUserId && room[cols[1]] == currentUserId)) {
                  return room['id'];
                }
              }
            }
          }
        } catch (e3) {
          print('Final attempt failed: $e3');
        }
        
        throw Exception('Could not create or find a chat room after multiple attempts');
      }
    }
  }
  
  // A simple method to send a message
  Future<void> sendMessage(String chatRoomId, String content) async {
    try {
      await _supabase.from('messages').insert({
        'chat_room_id': chatRoomId,
        'sender_id': currentUserId,
        'content': content,
      });
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }
  
  // Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _supabase.from('users').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId);
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
