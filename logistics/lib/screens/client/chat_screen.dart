import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logistics/screens/client/emoji_picker_widget.dart';
import 'package:logistics/screens/client/message_bubble.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final ChatUser otherUser;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUser,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isEmojiPickerVisible = false;
  ChatMessage? _replyToMessage;
  bool _isTyping = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.chatRoomId.isEmpty || widget.otherUser.id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid chat room or user')),
        );
        Navigator.pop(context);
      });
    } else {
      _loadMessages();
      _markMessagesAsRead();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _chatService
        .getMessages(widget.chatRoomId)
        .listen(
          (messages) {
            setState(() {
              _messages = messages;
              _isLoading = false;
            });
            _scrollToBottom();
          },
          onError: (e) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load messages: $e')),
            );
          },
        );
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.chatRoomId, widget.otherUser.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_replyToMessage != null) _buildReplyPreview(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe =
                            message.senderId == _chatService.currentUserId;

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          onReply: () => _setReplyMessage(message),
                          onDelete: () => _deleteMessage(message),
                          onCopy: () => _copyMessage(message),
                        );
                      },
                    ),
          ),
          _buildMessageInput(),
          if (_isEmojiPickerVisible) _buildEmojiPicker(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                widget.otherUser.profileImg != null
                    ? NetworkImage(widget.otherUser.profileImg!)
                    : null,
            child:
                widget.otherUser.profileImg == null
                    ? Text(
                      widget.otherUser.fullName.isNotEmpty
                          ? widget.otherUser.fullName
                              .substring(0, 1)
                              .toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.fullName.isNotEmpty
                      ? widget.otherUser.fullName
                      : 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.otherUser.isOnline
                      ? 'Online'
                      : widget.otherUser.lastSeen != null
                      ? 'Last seen ${_formatLastSeen(widget.otherUser.lastSeen!)}'
                      : 'Offline',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _showClearChatDialog();
                break;
              case 'block':
                _showBlockUserDialog();
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      const Text('Clear Chat'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Block User'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Colors.blue, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.senderId == _chatService.currentUserId ? 'yourself' : widget.otherUser.fullName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyToMessage!.type == MessageType.image
                      ? '📷 Photo'
                      : _replyToMessage!.message ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyToMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              onChanged: (text) {
                setState(() {
                  _isTyping = text.isNotEmpty;
                });
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(
              _isEmojiPickerVisible ? Icons.keyboard : Icons.emoji_emotions,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _isEmojiPickerVisible = !_isEmojiPickerVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isTyping ? Icons.send : Icons.mic,
              color: Colors.blue[600],
            ),
            onPressed: _isTyping ? _sendMessage : _recordVoiceMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPickerWidget(
        onEmojiSelected: (emoji) {
          _messageController.text += emoji;
          setState(() {
            _isTyping = _messageController.text.isNotEmpty;
          });
        },
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isTyping = false;
      _isEmojiPickerVisible = false;
    });

    try {
      await _chatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        receiverId: widget.otherUser.id,
        message: message,
        replyToId: _replyToMessage?.id,
      );

      setState(() {
        _replyToMessage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _pickAndSendImage(ImageSource source) async {
    try {
      final imageFile = await _chatService.pickImage(source: source);
      if (imageFile != null) {
        await _chatService.sendImageMessage(
          chatRoomId: widget.chatRoomId,
          receiverId: widget.otherUser.id,
          imageFile: imageFile,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
    }
  }

  void _recordVoiceMessage() {
    // Placeholder for voice message recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice messages are not yet implemented')),
    );
    // TODO: Implement voice message recording (e.g., using a package like flutter_sound)
  }

  void _setReplyMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _deleteMessage(ChatMessage message) async {
    if (message.senderId != _chatService.currentUserId) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _chatService.deleteMessage(message.id);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete message: $e')));
      }
    }
  }

  void _copyMessage(ChatMessage message) {
    if (message.message != null) {
      Clipboard.setData(ClipboardData(text: message.message!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message copied to clipboard')),
      );
    }
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat'),
            content: const Text(
              'Are you sure you want to clear all messages in this chat?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _chatService.clearChat(widget.chatRoomId);
                    setState(() {
                      _messages = [];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat cleared successfully'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to clear chat: $e')),
                    );
                  }
                },
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Block User'),
            content: Text(
              'Are you sure you want to block ${widget.otherUser.fullName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _chatService.blockUser(widget.otherUser.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.otherUser.fullName} blocked'),
                      ),
                    );
                    Navigator.pop(context); // Return to previous screen
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to block user: $e')),
                    );
                  }
                },
                child: const Text('Block', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
