import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/conversation/controllers/chat_controller.dart';
import 'package:torko/data/models/message_model.dart';
import 'package:torko/core/services/user_info.dart';

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
  bool _shouldAutoScroll = true; // Track if user is near bottom for smart auto-scroll

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    // Track if user is near bottom (within 200px)
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      final threshold = maxScroll - 200;
      _shouldAutoScroll = currentScroll >= threshold;
    }
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
    final token = UserInfo.apiToken;
    
    // Try route arguments first (from inbox navigation)
    // Support both standardized format (to_user_id, fullname, profile_image) and legacy format
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Try standardized format first
      int? toUserId = args['to_user_id'] is int 
          ? args['to_user_id'] 
          : (args['to_user_id'] != null ? int.tryParse(args['to_user_id'].toString()) : null);
      
      // Fallback to legacy format
      if (toUserId == null || toUserId == 0) {
        toUserId = args['toUserId'] is int 
            ? args['toUserId'] 
            : (args['toUserId'] != null ? int.tryParse(args['toUserId'].toString()) : null);
      }
      
      if (toUserId != null && toUserId > 0) {
        _conversationArgs = args;
        
        // Get receiver info (standardized or legacy)
        final receiverName = args['fullname']?.toString() ?? args['receiverName']?.toString();
        final receiverAvatar = args['profile_image']?.toString() ?? args['receiverAvatar']?.toString();
        
        await chatController.initChat(
          toUserId: toUserId,
          receiverName: receiverName,
          receiverAvatar: receiverAvatar,
        );
        // Scroll to bottom after initial load
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(force: true));
        return;
      } else {
        // Invalid user ID
        chatController.errorMessage.value = 'Invalid user';
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
        await chatController.initChat(
          toUserId: toUserId,
          receiverName: receiverName?.toString(),
          receiverAvatar: receiverAvatar?.toString(),
        );
        // Scroll to bottom after initial load
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(force: true));
      }

    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    chatController.clearChat();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool force = false}) {
    // Only auto-scroll if user is near bottom (unless forced)
    if (!force && !_shouldAutoScroll) return;
    
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
    messageController.clear(); // Clear immediately (Firestore stream updates UI)
    _shouldAutoScroll = true;

    final success = await chatController.sendMessage(content);
    if (success) {
      _scrollToBottom(force: true);
    } else {
      messageController.text = content; // Restore on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Do NOT wrap entire build in Obx()
    // Only specific widgets use Obx for granular reactivity
    
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
    
    // CRITICAL: Do NOT use PostFrameCallback in build()
    // Scroll handling is done via scroll listener or explicit calls
    
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
            // CRITICAL: Only message list uses Obx for granular reactivity
            Expanded(
              child: Obx(() {
                // Explicit dependency so new Reverb messages trigger rebuild immediately
                final _ = chatController.messagesVersion.value;
                final messageCount = chatController.messages.length;
                final isLoading = chatController.isLoading.value;
                final errorMsg = chatController.errorMessage.value;
                
                // Show error if invalid user or other error
                if (errorMsg.isNotEmpty && !isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMsg == 'Invalid user' 
                              ? (isBn ? 'অবৈধ ব্যবহারকারী' : 'Invalid user')
                              : errorMsg,
                          style: TextStyle(
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(isBn ? 'ফিরে যান' : 'Go Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightPrimary,
                    ),
                  );
                }

                if (messageCount == 0) {
                  return Center(
                    child: Text(
                      isBn ? 'কোন মেসেজ নেই' : 'No messages yet',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  );
                }

                // Auto-scroll when new messages arrive (if user is near bottom)
                // Use PostFrameCallback to ensure scroll happens after build
                if (_shouldAutoScroll) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }

                return ListView.builder(
                  // CRITICAL: Add key to force rebuild when message count changes
                  key: ValueKey('messages_$messageCount'),
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messageCount,
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
