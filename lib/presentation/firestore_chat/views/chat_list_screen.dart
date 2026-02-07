import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/app/routes/app_routes.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/core/services/firebase_auth_service.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/presentation/firestore_chat/controllers/firestore_chat_list_controller.dart';
import 'package:torko/presentation/firestore_chat/controllers/firestore_chat_room_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Firestore chat list screen.
/// Lists conversations for current uid with lastMessage and unread count.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Guard: never show inbox before auth is ready
    final uid = UserInfo.myUidString;
    if (uid == null || uid.isEmpty) {
      if (kDebugMode) AppLogger.nav('ChatList: No uid → redirecting to Login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.lightPrimary)),
      );
    }
    // Controller created by FirestoreChatListBinding
    final listCtrl = Get.find<FirestoreChatListController>();
    final appCtrl = Get.find<AppController>();
    final isDark = appCtrl.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_comment,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            onPressed: () => _showNewChatDialog(context, listCtrl, isDark),
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (listCtrl.isLoading.value && listCtrl.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary));
        }
        if (listCtrl.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  listCtrl.error.value,
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => listCtrl.refresh(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (listCtrl.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: listCtrl.conversations.length,
          itemBuilder: (context, i) {
            final item = listCtrl.conversations[i];
            return _ConversationTile(
              item: item,
              isDark: isDark,
              onTap: () {
                Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'conversationId': item.conversation.id,
                    'otherUid': item.otherUid,
                    'displayName': item.displayName,
                    'avatarUrl': item.avatarUrl,
                  },
                );
              },
            );
          },
        );
      }),
    );
  }

  void _logout() async {
    if (kDebugMode) AppLogger.auth('Auth state: SIGNED OUT');
    await FirebaseAuthService().signOut();
    await UserInfo.clear();
    if (kDebugMode) AppLogger.nav('Post-logout → Login');
    Get.offAllNamed(AppRoutes.login);
  }

  void _showNewChatDialog(
    BuildContext context,
    FirestoreChatListController listCtrl,
    bool isDark,
  ) {
    final uidController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        title: Text(
          'New Chat',
          style: TextStyle(color: isDark ? AppColors.darkForeground : AppColors.lightForeground),
        ),
        content: TextField(
          controller: uidController,
          decoration: InputDecoration(
            hintText: 'Enter user ID (e.g. 70)',
            hintStyle: TextStyle(color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
          ),
          style: TextStyle(color: isDark ? AppColors.darkForeground : AppColors.lightForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.lightPrimary)),
          ),
          TextButton(
            onPressed: () async {
              final uid = uidController.text.trim();
              Navigator.pop(ctx);
              if (uid.isEmpty) return;
              try {
                // Controller created when navigating to chat (binding)
                if (!Get.isRegistered<FirestoreChatRoomController>()) {
                  Get.put(FirestoreChatRoomController(), permanent: false);
                }
                final roomCtrl = Get.find<FirestoreChatRoomController>();
                await roomCtrl.initNewChat(uid);
                Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'conversationId': roomCtrl.conversationId.value,
                    'otherUid': roomCtrl.otherUid.value,
                    'displayName': roomCtrl.otherUser.value?.fullname ?? roomCtrl.otherUid.value,
                    'avatarUrl': null,
                  },
                );
              } catch (e) {
                if (kDebugMode) debugPrint('[CHAT] Create chat failed: $e');
                Get.snackbar('Error', 'Could not start chat. Please try again.');
              }
            },
            child: Text('Start', style: TextStyle(color: AppColors.lightPrimary)),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final FirestoreConversationWithOther item;
  final bool isDark;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
                  backgroundImage: item.avatarUrl != null && item.avatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(item.avatarUrl!)
                      : null,
                  child: item.avatarUrl == null || item.avatarUrl!.isEmpty
                      ? Text(
                          item.displayName.isNotEmpty ? item.displayName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.lightPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (item.unreadCount > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        item.unreadCount > 9 ? '9+' : item.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: TextStyle(
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            fontSize: 16,
                            fontWeight: item.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(item.conversation.lastMessageAt),
                        style: TextStyle(
                          color: item.unreadCount > 0
                              ? AppColors.lightPrimary
                              : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.conversation.lastMessage.isEmpty
                        ? 'No messages yet'
                        : item.conversation.lastMessage,
                    style: TextStyle(
                      color: item.unreadCount > 0
                          ? (isDark ? AppColors.darkForeground : AppColors.lightForeground)
                          : (isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final d = now.difference(dt);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
