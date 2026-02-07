import 'package:get/get.dart';
import 'package:torko/presentation/firestore_chat/controllers/firestore_chat_list_controller.dart';
import 'package:torko/presentation/firestore_chat/controllers/firestore_chat_room_controller.dart';

/// Bindings for Firestore chat (chatList, chat) routes.
/// Controllers created once per route push, not in build().
class FirestoreChatListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirestoreChatListController>()) {
      Get.put(FirestoreChatListController(), permanent: false);
    }
  }
}

/// Binding for chat room route.
class FirestoreChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirestoreChatRoomController>()) {
      Get.put(FirestoreChatRoomController(), permanent: false);
    }
  }
}
