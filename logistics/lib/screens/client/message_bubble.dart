import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReply,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) _buildAvatar(),
            if (!isMe) SizedBox(width: 8),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[600] : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.replyToId != null) _buildReplyPreview(),
                    _buildMessageContent(),
                    SizedBox(height: 4),
                    _buildMessageInfo(),
                  ],
                ),
              ),
            ),
            if (isMe) SizedBox(width: 8),
            if (isMe) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 12,
      backgroundImage:
          message.sender?.profileImg != null
              ? NetworkImage(message.sender!.profileImg!)
              : null,
      child:
          message.sender?.profileImg == null
              ? Text(
                message.sender?.fullName.isNotEmpty ?? false
                    ? message.sender!.fullName.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              )
              : null,
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: isMe ? Colors.white : Colors.blue, width: 3),
        ),
      ),
      child: Text(
        'Replying to message...',
        style: TextStyle(
          color: isMe ? Colors.white70 : Colors.grey[600],
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.emoji:
        return _buildEmojiMessage();
      case MessageType.text:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.message ?? '',
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.imageUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                ),
          ),
        ),
        if (message.message != null && message.message!.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            message.message!,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmojiMessage() {
    return Text(message.message ?? '😊', style: TextStyle(fontSize: 32));
  }

  Widget _buildMessageInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: TextStyle(
            color: isMe ? Colors.white70 : Colors.grey[600],
            fontSize: 11,
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 4),
          Icon(
            message.isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: message.isRead ? Colors.blue[200] : Colors.white70,
          ),
        ],
      ],
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.reply, color: Colors.blue),
                  title: Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    onReply();
                  },
                ),
                if (message.message != null)
                  ListTile(
                    leading: Icon(Icons.copy, color: Colors.green),
                    title: Text('Copy'),
                    onTap: () {
                      Navigator.pop(context);
                      onCopy();
                    },
                  ),
                if (isMe)
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ),
              ],
            ),
          ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
