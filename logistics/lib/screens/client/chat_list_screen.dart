import 'package:flutter/material.dart';
import 'package:logistics/screens/client/chat_screen.dart';
import 'package:logistics/screens/client/user_selection_screen.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _chatService.updateOnlineStatus(true);
  }

  @override
  void dispose() {
    _chatService.updateOnlineStatus(false);
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    try {
      final rooms = await _chatService.getChatRooms();
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading chats: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _chatRooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadChatRooms,
                child: ListView.builder(
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    return _buildChatRoomTile(room);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserSelectionScreen()),
          );
          if (result == true) {
            _loadChatRooms();
          }
        },
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.chat),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a new conversation by tapping the + button',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    final otherUser = room.otherUser;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                otherUser.profileImg != null
                    ? NetworkImage(otherUser.profileImg!)
                    : null,
            child:
                otherUser.profileImg == null
                    ? Text(
                      otherUser.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          if (otherUser.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUser.fullName,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          if (room.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                room.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              _getLastMessageText(room.lastMessage),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.lastActivity != null)
            Text(
              _formatTime(room.lastActivity!),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
        ],
      ),
      onTap: () async {
        final chatRoomId = await _chatService.getOrCreateChatRoom(otherUser.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ChatScreen(chatRoomId: chatRoomId, otherUser: otherUser),
          ),
        ).then((_) => _loadChatRooms());
      },
    );
  }

  String _getLastMessageText(ChatMessage? message) {
    if (message == null) return 'No messages yet';

    switch (message.type) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.emoji:
        return message.message ?? '😊';
      case MessageType.text:
        return message.message ?? '';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
