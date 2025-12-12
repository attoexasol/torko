import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final appController = Get.find<AppController>();
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // Sample messages
  final List<Map<String, dynamic>> messages = [
    {'text': 'Hey! How are you?', 'isMe': false, 'time': '10:30 AM'},
    {'text': 'I\'m good! How about you?', 'isMe': true, 'time': '10:31 AM'},
    {'text': 'Great! Did you see the new post?', 'isMe': false, 'time': '10:32 AM'},
    {'text': 'Yes, it was amazing! 🎉', 'isMe': true, 'time': '10:33 AM'},
    {'text': 'Let\'s meet up this weekend', 'isMe': false, 'time': '10:35 AM'},
    {'text': 'Sounds good! Where?', 'isMe': true, 'time': '10:36 AM'},
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final conversationData = appController.conversationData;
      
      if (conversationData == null) return const SizedBox();
      
      final name = conversationData['name'] ?? 'User';
      final online = conversationData['online'] ?? false;
      
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
            onPressed: () => appController.closeConversation(),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.2),
                    child: Text(
                      name[0],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: online ? Colors.green : AppColors.lightMutedForeground,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.phone_outlined,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
              onPressed: () {
                appController.startCall({'name': name, 'isVideo': false});
              },
            ),
            IconButton(
              icon: Icon(
                Icons.videocam_outlined,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
              onPressed: () {
                appController.startCall({'name': name, 'isVideo': true});
              },
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(
                    text: message['text'],
                    isMe: message['isMe'],
                    time: message['time'],
                    isDark: isDark,
                  );
                },
              ),
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
              child: Row(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: messageController,
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (messageController.text.isNotEmpty) {
                        setState(() {
                          messages.add({
                            'text': messageController.text,
                            'isMe': true,
                            'time': 'Now',
                          });
                          messageController.clear();
                        });
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent + 100,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
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
              child: Text(
                text,
                style: TextStyle(
                  color: isMe 
                      ? Colors.white 
                      : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
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
