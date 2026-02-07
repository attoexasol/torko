import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:torko/core/ids/user_id.dart';
import 'package:torko/core/repositories/chat_repository.dart';
import 'package:torko/core/repositories/user_repository.dart';
import 'package:torko/core/services/user_info.dart';
import 'package:torko/core/utils/app_logger.dart';
import 'package:torko/data/models/firestore/firestore_conversation.dart';
import 'package:torko/data/models/firestore/firestore_user.dart';

/// Controller for Firestore chat list.
/// Exposes conversation list stream with other user info.
class FirestoreChatListController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();

  final RxList<FirestoreConversationWithOther> conversations =
      <FirestoreConversationWithOther>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<FirestoreConversation>>? _subscription;

  String? get myUid => UserInfo.myUidString;

  static String _maskUid(String? uid) =>
      uid == null || uid.isEmpty ? 'null' : 'len=${uid.length}';

  @override
  void onInit() {
    super.onInit();
    // Defer stream to next frame - show UI first (performance)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) _subscribe();
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void refresh() {
    _subscribe();
  }

  void _subscribe() {
    final uid = myUid;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      error.value = 'Not logged in';
      return;
    }

    _subscription?.cancel();
    _subscription = _chatRepo.conversationsStream(uid).listen(
      (list) async {
        if (isClosed) return;
        final withOther = <FirestoreConversationWithOther>[];
        for (final c in list) {
          final peerRaw = c.members.firstWhere(
            (m) => m != uid,
            orElse: () => '',
          );
          final peerUid = peerRaw.isNotEmpty ? normalizeUserId(peerRaw) : '';
          FirestoreUser? other;
          if (peerUid.isNotEmpty) {
            try {
              other = await _userRepo.getUser(peerUid);
            } catch (_) {
              other = null;
            }
          }
          withOther.add(FirestoreConversationWithOther(
            conversation: c,
            otherUser: other,
            otherUid: peerUid,
            myUid: uid,
          ));
        }
        if (!isClosed) {
          conversations.assignAll(withOther);
          isLoading.value = false;
          error.value = '';
        }
      },
      onError: (e) {
        if (!isClosed) {
          error.value = AppLogger.toUserMessage(e);
          isLoading.value = false;
        }
      },
    );
  }

}

class FirestoreConversationWithOther {
  final FirestoreConversation conversation;
  final FirestoreUser? otherUser;
  final String otherUid;
  final String myUid;

  FirestoreConversationWithOther({
    required this.conversation,
    this.otherUser,
    required this.otherUid,
    required this.myUid,
  });

  String get displayName =>
      otherUser?.fullname ?? otherUser?.phone ?? (otherUid.isNotEmpty ? 'User $otherUid' : 'Unknown');
  String? get avatarUrl => otherUser?.profileImage;
  int get unreadCount => conversation.unreadFor(myUid);
}
