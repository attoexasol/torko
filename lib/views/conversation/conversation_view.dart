import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import '../../services/user_info.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final appController = Get.find<AppController>();
  late final ChatController chatController;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  Map<String, dynamic>? _conversationArgs;

  @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _initializeChat();
      _hasInitialized = true;
    }
  }

  Future<void> _initializeChat() async {
    // Try route arguments first (from inbox navigation)
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final toUserId = args['toUserId'];
      if (toUserId != null && toUserId is int) {
        _conversationArgs = args;
        await chatController.init(
          toUserId: toUserId,
          receiverName: args['receiverName']?.toString(),
          receiverAvatar: args['receiverAvatar']?.toString(),
        );
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return;
      }
    }

    // Fallback to appController.conversationData (from overlay system)
    final conversationData = appController.conversationData;
    if (conversationData != null) {
      _conversationArgs = conversationData;
      final toUserId = conversationData['toUserId'];
      final receiverName = conversationData['name'];
      final receiverAvatar = conversationData['avatar'];

      if (toUserId != null && toUserId is int) {
        await chatController.init(
          toUserId: toUserId,
          receiverName: receiverName?.toString(),
          receiverAvatar: receiverAvatar?.toString(),
        );
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }

    }
  }

  @override
  void dispose() {
    chatController.clearChat();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && chatController.messages.isNotEmpty) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (chatController.isSending.value) return;

    final content = messageController.text.trim();
    
    final success = await chatController.sendMessage(content);
    if (success) {
      // Only clear input on success
      messageController.clear();
      _scrollToBottom();
    }
    // If failed, keep the text so user can retry
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final isBn = appController.language == AppLanguage.bn;
      
      // Get conversation data from route args or appController
      final conversationData = _conversationArgs ?? appController.conversationData;
      if (conversationData == null) return const SizedBox();
      
      final name = conversationData['name']?.toString() ?? 
                   conversationData['receiverName']?.toString() ?? 
                   'User';
      final online = conversationData['online'] ?? false;
      final currentUserId = UserInfo.userId;
      
      // Scroll to bottom when messages load or new messages arrive
      if (chatController.messages.isNotEmpty && !chatController.isLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      
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
            onPressed: () {
              if (Get.arguments != null) {
                Get.back();
              } else {
                appController.closeConversation();
              }
            },
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.lightPrimary.withOpacity(0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: AppColors.lightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (online)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                            width: 2,
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
                    Text(
                      name,
                      style: TextStyle(
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      online ? (isBn ? 'অনলাইন' : 'Online') : (isBn ? 'অফলাইন' : 'Offline'),
                      style: TextStyle(
                        color: online ? Colors.green : AppColors.lightMutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // actions: [
          //   IconButton(
          //     icon: Icon(
          //       Icons.phone_outlined,
          //       color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          //     ),
          //     onPressed: () {
          //       appController.startCall({'name': name, 'isVideo': false});
          //     },
          //   ),
          //   IconButton(
          //     icon: Icon(
          //       Icons.videocam_outlined,
          //       color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          //     ),
          //     onPressed: () {
          //       appController.startCall({'name': name, 'isVideo': true});
          //     },
          //   ),
          //   IconButton(
          //     icon: Icon(
          //       Icons.more_vert,
          //       color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          //     ),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: Obx(() {
                if (chatController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightPrimary,
                    ),
                  );
                }

                if (chatController.messages.isEmpty) {
                  return Center(
                    child: Text(
                      isBn ? 'কোন মেসেজ নেই' : 'No messages yet',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatController.messages[index];
                    final isMe = currentUserId != null && message.isMine(currentUserId);
                    
                    return _buildMessageBubble(
                      message: message,
                      isMe: isMe,
                      isDark: isDark,
                    );
                  },
                );
              }),
            ),
            
            // Input Area
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
              child: Obx(() => Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.lightPrimary,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: messageController,
                        enabled: !chatController.isSending.value,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: isBn ? 'মেসেজ লিখুন...' : 'Message...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkMutedForeground
                                : AppColors.lightMutedForeground,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _handleSendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => GestureDetector(
                    onTap: chatController.isSending.value 
                        ? null 
                        : () {
                            if (messageController.text.trim().isNotEmpty) {
                              _handleSendMessage();
                            }
                          },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: chatController.isSending.value
                            ? AppColors.lightPrimary.withOpacity(0.5)
                            : AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: chatController.isSending.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  )),
                ],
              )),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble({
    required MessageModel message,
    required bool isMe,
    required bool isDark,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message.messageContent,
                      style: TextStyle(
                        color: isMe 
                            ? Colors.white 
                            : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (message.isSending || message.isFailed) ...[
                    const SizedBox(width: 8),
                    if (message.isSending)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isMe ? Colors.white70 : AppColors.lightMutedForeground,
                        ),
                      )
                    else if (message.isFailed)
                      Icon(
                        Icons.error_outline,
                        size: 12,
                        color: Colors.red,
                      ),
                  ],
                ],
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
