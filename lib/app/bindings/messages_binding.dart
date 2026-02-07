import 'package:get/get.dart';
import 'package:torko/presentation/conversation/controllers/chat_controller.dart';
import 'package:torko/presentation/messages/controllers/inbox_controller.dart';

/// Bindings for Messages + Conversation routes.
/// Controllers are permanent (singleton) - reused when switching tabs.
class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<InboxController>()) {
      Get.put(InboxController(), permanent: true);
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }
  }
}
