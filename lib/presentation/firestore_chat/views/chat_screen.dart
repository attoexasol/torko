import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/data/models/firestore/firestore_message.dart';
import 'package:torko/presentation/firestore_chat/controllers/firestore_chat_room_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Firestore chat screen.
/// Streams messages (orderBy createdAt desc, reversed for display) and send input.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  late FirestoreChatRoomController roomCtrl;

  @override
  void initState() {
    super.initState();
    roomCtrl = Get.put(FirestoreChatRoomController());
    if (roomCtrl.conversationId.value.isEmpty) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null) {
        final cid = args['conversationId']?.toString() ?? '';
        final otherUid = args['otherUid']?.toString() ?? '';
        if (cid.isNotEmpty && otherUid.isNotEmpty) {
          roomCtrl.initChat(cid, otherUid);
        }
      }
    }
  }

  @override
  void dispose() {
    roomCtrl.clear();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    if (roomCtrl.isSending.value) return;
    final ok = await roomCtrl.sendMessage(text);
    if (ok) {
      messageController.clear();
    } else {
      Get.snackbar('Error', roomCtrl.error.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final isDark = appCtrl.isDarkMode;
    final myUid = UserInfo.myUidString;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final other = roomCtrl.otherUser.value;
          final name = other?.fullname ?? other?.phone ?? roomCtrl.otherUid.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
                backgroundImage: other?.profileImage != null && other!.profileImage!.isNotEmpty
                    ? CachedNetworkImageProvider(other.profileImage!)
                    : null,
                child: other?.profileImage == null || other!.profileImage!.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final list = roomCtrl.messages;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final msg = list[i];
                  final isMe = myUid != null && msg.isMine(myUid);
                  return _MessageBubble(
                    message: msg,
                    isMe: isMe,
                    isDark: isDark,
                  );
                },
              );
            }),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: messageController,
                      enabled: !roomCtrl.isSending.value,
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => GestureDetector(
                  onTap: roomCtrl.isSending.value ? null : _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: roomCtrl.isSending.value
                          ? AppColors.lightPrimary.withOpacity(0.5)
                          : AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: roomCtrl.isSending.value
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final FirestoreMessage message;
  final bool isMe;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.lightPrimary
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: TextStyle(
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
