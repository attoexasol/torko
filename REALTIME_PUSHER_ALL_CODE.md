# All Code Used for Realtime Messaging & Pusher

Complete reference of every file and snippet used for Pusher and real-time chat in Torko.

---

## 1. `lib/services/pusher_service.dart` (full)

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/message_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';
import '../services/user_info.dart';

/// Singleton PusherService – real-time messaging lifecycle.
class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter? _pusher;
  PusherChannel? _channel;
  String? _currentChannelName;

  StreamController<MessageModel> _controller =
      StreamController<MessageModel>.broadcast();

  bool _initialized = false;
  bool _connected = false;
  int? _currentUserId;
  bool _initializing = false;
  bool _disconnecting = false;

  static const String _pusherKey = '9df09725d514e737df9a';
  static const String _pusherCluster = 'ap2';

  Stream<MessageModel> get stream => _controller.stream;
  Stream<MessageModel> get incomingMessages => stream;
  Stream<MessageModel> get messagesStream => stream;
  bool get isConnected => _connected;
  int? get currentUserId => _currentUserId;

  Future<void> init({required int userId}) async {
    if (_initializing) return;
    if (_connected && _currentUserId == userId) return;

    _initializing = true;
    try {
      if (_connected || _initialized) await disconnect();

      _currentUserId = userId;
      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onAuthorizer: _onAuthorizer,
        onConnectionStateChange: (currentState, previousState) {
          final stateStr = currentState.toString();
          final u = stateStr.toUpperCase();
          final isConnected =
              u.contains('CONNECTED') && !u.contains('CONNECTING');
          final isDisconnected =
              u.contains('DISCONNECTED') || u.contains('FAILED');
          if (isConnected) {
            _connected = true;
            _subscribe(userId);
          } else {
            _connected = false;
          }
        },
        onError: (message, code, error) {},
        onSubscriptionSucceeded: (channelName, data) {},
        onEvent: (event) {
          if (event.eventName == 'message.sent') _handleEvent(event);
        },
        onSubscriptionError: (message, error) {},
      );

      await _pusher!.connect();
      await Future.delayed(const Duration(seconds: 1));
      _initialized = true;
    } catch (e) {
      _initialized = false;
      _connected = false;
      _currentUserId = null;
      _currentChannelName = null;
      rethrow;
    } finally {
      _initializing = false;
    }
  }

  Future<void> _subscribe(int userId) async {
    _currentChannelName = 'private-chat.$userId';
    try {
      _channel = await _pusher!.subscribe(channelName: _currentChannelName!);
    } catch (e) {
      _currentChannelName = null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) throw Exception('No API token');
    final response = await NetworkCaller.postAuth(
      url: Urls.pusher_auth,
      body: { 'socket_id': socketId, 'channel_name': channelName },
    );
    if (!response.isSuccess || response.body == null)
      throw Exception('Auth failed: ${response.errorMessage ?? 'Unknown'}');
    final authData = response.body!;
    final auth = authData['auth'] as String?;
    if (auth == null || auth.isEmpty)
      throw Exception('Invalid auth response: missing auth field');
    return {'auth': auth};
  }

  void _handleEvent(PusherEvent event) {
    try {
      Map<String, dynamic> raw;
      if (event.data is String) {
        raw = jsonDecode(event.data as String) as Map<String, dynamic>;
      } else if (event.data is Map) {
        raw = Map<String, dynamic>.from(event.data as Map);
      } else return;

      Map<String, dynamic> payload = raw;
      if (raw.containsKey('data') && raw['data'] is Map)
        payload = Map<String, dynamic>.from(raw['data'] as Map);
      else if (raw.containsKey('message') && raw['message'] is Map)
        payload = Map<String, dynamic>.from(raw['message'] as Map);

      if (!payload.containsKey('id') || !payload.containsKey('from_user_id'))
        return;

      final message = MessageModel.fromJson(payload);
      _controller.add(message);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PUSHER] payload parse error: $e');
        debugPrint('[PUSHER] raw event.data: ${event.data}');
      }
    }
  }

  Future<void> disconnect() async {
    if (_disconnecting) return;
    if (!_initialized && _channel == null && _pusher == null &&
        _currentChannelName == null) return;

    _disconnecting = true;
    try {
      if (_currentChannelName != null && _pusher != null) {
        try {
          await _pusher!.unsubscribe(channelName: _currentChannelName!);
        } catch (e) {}
        _channel = null;
        _currentChannelName = null;
      }
      if (_pusher != null) {
        try { await _pusher!.disconnect(); } catch (e) {}
        _pusher = null;
      }
      _initialized = false;
      _connected = false;
      _currentUserId = null;
      _currentChannelName = null;
    } finally {
      _disconnecting = false;
    }
  }

  void dispose() {
    _controller.close();
    disconnect();
    _initialized = false;
    _connected = false;
    _currentUserId = null;
    _currentChannelName = null;
  }
}
```

---

## 2. `lib/controllers/chat_controller.dart` (full)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/controllers/app_controller.dart';
import 'inbox_controller.dart';

// STREAM-ONLY updates. API only: initChat, sendMessage.

class ChatController extends GetxController {
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int? currentUserId;
  int? activeUserId;
  int? toUserId;
  String? receiverName;
  String? receiverAvatar;

  final Set<int> receivedMessageIds = <int>{};
  StreamSubscription<MessageModel>? _pusherSubscription;
  final Map<int, bool> _conversationLoaded = <int, bool>{};

  ChatController() {
    _attachRealtimeListener();
  }

  void _attachRealtimeListener() {
    _pusherSubscription?.cancel();
    _pusherSubscription = null;
    _pusherSubscription = PusherService().incomingMessages.listen(
      (message) => _handleIncomingMessage(message),
      onError: (error) {},
      cancelOnError: false,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> initChat({
    required int toUserId,
    String? receiverName,
    String? receiverAvatar,
  }) async {
    final currentUser = UserInfo.userId;
    if (currentUser == null) {
      errorMessage.value = 'User not logged in';
      return;
    }
    if (activeUserId == toUserId && _conversationLoaded[toUserId] == true) {
      this.toUserId = toUserId;
      this.receiverName = receiverName;
      this.receiverAvatar = receiverAvatar;
      return;
    }

    final previousActiveUserId = activeUserId;
    currentUserId = currentUser;
    activeUserId = toUserId;
    this.toUserId = toUserId;
    this.receiverName = receiverName;
    this.receiverAvatar = receiverAvatar;
    errorMessage.value = '';

    if (previousActiveUserId != null && previousActiveUserId != toUserId) {
      messages.clear();
      receivedMessageIds.clear();
    }

    if (_conversationLoaded[toUserId] != true) {
      await loadConversationOnce(toUserId);
      _conversationLoaded[toUserId] = true;
    }
  }

  Future<void> loadConversationOnce(int userId) async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final history = await MessageApiService.fetchConversation(
        token: token,
        toUserId: userId,
      );
      final existingIds = receivedMessageIds.toSet();
      final newMessages = <MessageModel>[];
      for (var msg in history) {
        if (!existingIds.contains(msg.id)) {
          newMessages.add(msg);
          receivedMessageIds.add(msg.id);
        }
      }
      final allMessages = [...messages, ...newMessages];
      allMessages.sort((a, b) {
        final tc = a.createdAt.compareTo(b.createdAt);
        if (tc != 0) return tc;
        return a.id.compareTo(b.id);
      });
      messages.value = allMessages;
    } catch (e) {
      errorMessage.value = e is MessageApiException
          ? e.message
          : 'Failed to load conversation';
    } finally {
      isLoading.value = false;
    }
  }

  void _handleIncomingMessage(MessageModel message) {
    try {
      if (activeUserId == null || currentUserId == null) return;
      final isIncoming = message.fromUserId == activeUserId &&
          message.toUserId == currentUserId;
      final isOutgoing = message.fromUserId == currentUserId &&
          message.toUserId == activeUserId;
      if (!isIncoming && !isOutgoing) return;
      if (receivedMessageIds.contains(message.id)) return;

      receivedMessageIds.add(message.id);
      if (!messages.any((m) => m.id == message.id)) {
        _addMessageSorted(message);
        messages.refresh();
      }
      _notifyInboxUpdate(message);
    } catch (e) {}
  }

  void _addMessageSorted(MessageModel message) {
    int insertIndex = messages.length;
    for (int i = 0; i < messages.length; i++) {
      final existing = messages[i];
      final c = message.createdAt.compareTo(existing.createdAt);
      if (c < 0) { insertIndex = i; break; }
      if (c == 0 && message.id < existing.id) { insertIndex = i; break; }
    }
    final newMessages = List<MessageModel>.from(messages);
    newMessages.insert(insertIndex, message);
    messages.value = newMessages;
  }

  void _notifyInboxUpdate(MessageModel message) {
    try {
      if (Get.isRegistered<InboxController>()) {
        Get.find<InboxController>().updateConversationFromMessage(message);
      }
    } catch (e) {}
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;
    if (toUserId == null || currentUserId == null) return false;
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return false;
    if (toUserId == currentUserId) return false;

    isSending.value = true;
    errorMessage.value = '';
    final tempMessage = MessageModel.temporary(
      fromUserId: currentUserId!,
      toUserId: toUserId!,
      messageContent: content.trim(),
    );
    messages.add(tempMessage);
    receivedMessageIds.add(tempMessage.id);
    messages.refresh();

    try {
      final sentMessage = await MessageApiService.sendMessage(
        token: token,
        toUserId: toUserId!,
        content: content.trim(),
      );
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1)
        messages[index] = sentMessage;
      else
        messages.add(sentMessage);
      receivedMessageIds.remove(tempMessage.id);
      receivedMessageIds.add(sentMessage.id);
      messages.refresh();
      isSending.value = false;
      _notifyInboxUpdate(sentMessage);
      return true;
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages.removeAt(index);
        messages.refresh();
      }
      errorMessage.value = e is MessageApiException
          ? e.message
          : 'Failed to send message';
      isSending.value = false;
      return false;
    }
  }

  void clearChat() {
    activeUserId = null;
    toUserId = null;
    receiverName = null;
    receiverAvatar = null;
    messages.clear();
    receivedMessageIds.clear();
    _conversationLoaded.clear();
    errorMessage.value = '';
    isSending.value = false;
    isLoading.value = false;
  }
}
```

---

## 3. `lib/controllers/inbox_controller.dart` (realtime-related)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/message_row_model.dart';
import '../models/inbox_thread_model.dart';
import '../models/message_model.dart';
import '../models/user_mini_model.dart';
import '../services/message_api_service.dart';
import '../services/pusher_service.dart';
import '../services/user_info.dart';
import '../core/routes/app_routes.dart';

// STREAM-ONLY updates. API only: loadInboxOnce, refresh, search.

class InboxController extends GetxController {
  final RxList<InboxThreadModel> threads = <InboxThreadModel>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  StreamSubscription<MessageModel>? _pusherSubscription;
  bool _loadedOnce = false;

  @override
  void onInit() {
    super.onInit();
    _connectPusher();
  }

  void loadInboxOnce() {
    if (_loadedOnce) return;
    _loadedOnce = true;
    fetchInbox();
  }

  void resetLoadedFlag() {
    _loadedOnce = false;
  }

  void _connectPusher() {
    _pusherSubscription?.cancel();
    _pusherSubscription = null;
    _pusherSubscription = PusherService().incomingMessages.listen(
      (message) => _handleIncomingMessage(message),
      onError: (error) {},
      cancelOnError: false,
    );
  }

  void _handleIncomingMessage(MessageModel message) {
    try {
      final currentUserId = UserInfo.userId;
      if (currentUserId == null) return;
      final otherUserId = message.fromUserId == currentUserId
          ? message.toUserId
          : message.fromUserId;
      final threadIndex = threads.indexWhere((t) => t.otherUserId == otherUserId);

      if (threadIndex >= 0) {
        final existingThread = threads[threadIndex];
        final lastRow = MessageRowModel(
          id: message.id,
          fromUserId: message.fromUserId,
          toUserId: message.toUserId,
          content: message.messageContent,
          isRead: message.isRead,
          createdAt: message.createdAt,
          sender: message.sender,
          receiver: message.receiver,
        );
        int newUnreadCount = existingThread.unreadCount;
        if (message.toUserId == currentUserId && message.isRead == 0)
          newUnreadCount = existingThread.unreadCount + 1;
        else if (message.fromUserId == currentUserId)
          newUnreadCount = existingThread.unreadCount;

        final updatedThread = InboxThreadModel(
          otherUserId: existingThread.otherUserId,
          otherName: existingThread.otherName,
          otherAvatar: existingThread.otherAvatar,
          lastMessage: message.messageContent,
          lastTime: message.createdAt,
          unreadCount: newUnreadCount,
          lastRow: lastRow,
        );
        threads[threadIndex] = updatedThread;
        final updated = threads.removeAt(threadIndex);
        threads.insert(0, updated);
        threads.refresh();
      } else {
        if (message.sender != null && message.receiver != null) {
          final otherUser = message.fromUserId == currentUserId
              ? message.receiver!
              : message.sender!;
          final lastRow = MessageRowModel(
            id: message.id,
            fromUserId: message.fromUserId,
            toUserId: message.toUserId,
            content: message.messageContent,
            isRead: message.isRead,
            createdAt: message.createdAt,
            sender: message.sender,
            receiver: message.receiver,
          );
          final newThread = InboxThreadModel(
            otherUserId: otherUser.id,
            otherName: otherUser.fullname,
            otherAvatar: otherUser.profileImage,
            lastMessage: message.messageContent,
            lastTime: message.createdAt,
            unreadCount: message.toUserId == currentUserId && message.isRead == 0
                ? 1
                : 0,
            lastRow: lastRow,
          );
          threads.insert(0, newThread);
          threads.refresh();
        }
      }
    } catch (e) {}
  }

  Future<void> fetchInbox() async {
    final token = UserInfo.apiToken;
    if (token == null || token.isEmpty) return;
    final currentUserId = UserInfo.userId;
    if (currentUserId == null) return;
    loading.value = true;
    error.value = '';
    try {
      final rawRows = await MessageApiService.fetchInboxRows(token: token);
      // ... build threadMap from rawRows, then:
      // threads.assignAll(threadList);
    } catch (e) {
      error.value = e is MessageApiException ? e.message : 'Failed to load';
    } finally {
      loading.value = false;
    }
  }

  Future<void> refresh() async => fetchInbox();

  void openThreadFromInbox(InboxThreadModel thread) {
    Get.toNamed(AppRoutes.conversation, arguments: {
      'to_user_id': thread.otherUserId,
      'fullname': thread.otherName,
      'profile_image': thread.otherAvatar,
      'toUserId': thread.otherUserId,
      'receiverName': thread.otherName,
      'receiverAvatar': thread.otherAvatar,
    });
  }

  void updateConversationFromMessage(MessageModel message) {
    _handleIncomingMessage(message);
  }
}
```

---

## 4. `lib/core/bindings/initial_bindings.dart` (Pusher part)

```dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../services/app_lifecycle_service.dart';
import '../../services/pusher_service.dart';
import '../../services/user_info.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(InboxController(), permanent: true);
    Get.put(AppLifecycleService(), permanent: true);

    _initializePusherIfLoggedIn();

    Get.lazyPut(() => BottomNavController());
    Get.lazyPut(() => HomeHeaderController());
  }

  void _initializePusherIfLoggedIn() {
    final token = UserInfo.apiToken;
    final userId = UserInfo.userId;
    if (token == null || token.isEmpty || userId == null) return;
    PusherService().init(userId: userId).catchError((error) {
      if (kDebugMode) debugPrint('[InitialBindings] Pusher init failed: $error');
    });
  }
}
```

---

## 5. `lib/views/login/login_controller.dart` (Pusher part, after OTP verify)

```dart
// Inside handleOTPComplete(), after UserInfo updated (token, userId, verified):

final currentUserId = UserInfo.userId;
if (currentUserId != null) {
  try {
    await PusherService().disconnect();
    await PusherService().init(userId: currentUserId);
  } catch (e) {
    // Don't block navigation
  }
}
Get.offAllNamed(AppRoutes.profileData);
```

---

## 6. `lib/services/logout_service.dart` (Pusher + Chat/Inbox clear)

```dart
import 'pusher_service.dart';
import '../controllers/chat_controller.dart';
import '../controllers/inbox_controller.dart';
import 'user_info.dart';

class LogoutService {
  static Future<void> clearAllData() async {
    try {
      // 1. FIRST: Disconnect Pusher
      await PusherService().disconnect();

      // 2. Clear GetStorage (UserInfo)
      await UserInfo.eraseAll();

      // 3. Clear SharedPreferences
      await _clearSharedPreferences();

      // 4. Clear image cache
      await _clearImageCache();

      // 5. Clear controller states (including Chat, Inbox)
      _clearControllerStates();

      // 6. Delete non-permanent controllers (NOT Chat/Inbox)
      _deleteControllers();
    } catch (e) {}
  }

  static void _clearControllerStates() {
    // ...
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().clearChat();
    }
    if (Get.isRegistered<InboxController>()) {
      final ic = Get.find<InboxController>();
      ic.threads.clear();
      ic.searchResults.clear();
      ic.searchEC.clear();
      ic.isSearchMode.value = false;
      ic.searching.value = false;
      ic.searchError.value = '';
      ic.error.value = '';
      ic.loading.value = false;
      ic.resetLoadedFlag();
    }
  }

  static void _deleteControllers() {
    // Delete Post, Profile, Home, Comment, etc.
    // DO NOT delete ChatController or InboxController
  }
}
```

---

## 7. `lib/services/app_lifecycle_service.dart` (full)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'pusher_service.dart';
import 'user_info.dart';

class AppLifecycleService extends GetxController
    with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final userId = UserInfo.userId;
    final token = UserInfo.apiToken;
    if (userId == null || token == null || token.isEmpty) return;
    PusherService().init(userId: userId).catchError((e) {});
  }
}
```

---

## 8. `lib/models/message_model.dart` (fromJson + temporary)

```dart
import 'user_mini_model.dart';

class MessageModel {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String messageContent;
  final int isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserMiniModel? sender;
  final UserMiniModel? receiver;
  final bool isSending;
  final bool isFailed;

  MessageModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.messageContent,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.isSending = false,
    this.isFailed = false,
  });

  factory MessageModel.temporary({
    required int fromUserId,
    required int toUserId,
    required String messageContent,
  }) {
    final now = DateTime.now();
    return MessageModel(
      id: -now.millisecondsSinceEpoch,
      fromUserId: fromUserId,
      toUserId: toUserId,
      messageContent: messageContent,
      isRead: 0,
      createdAt: now,
      updatedAt: now,
      isSending: true,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt = json['created_at'] is String
        ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
        : DateTime.now();
    DateTime updatedAt = json['updated_at'] is String
        ? DateTime.tryParse(json['updated_at'] as String) ?? createdAt
        : createdAt;
    return MessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fromUserId: json['from_user_id'] is int ? json['from_user_id'] : int.tryParse(json['from_user_id'].toString()) ?? 0,
      toUserId: json['to_user_id'] is int ? json['to_user_id'] : int.tryParse(json['to_user_id'].toString()) ?? 0,
      messageContent: json['message_content']?.toString() ?? '',
      isRead: json['is_read'] is int ? json['is_read'] : (json['is_read'] == true ? 1 : 0),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sender: json['sender'] != null ? UserMiniModel.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? UserMiniModel.fromJson(json['receiver']) : null,
    );
  }

  bool isMine(int currentUserId) => fromUserId == currentUserId;
}
```

---

## 9. `lib/models/user_mini_model.dart` (full)

```dart
class UserMiniModel {
  final int id;
  final String fullname;
  final String? profileImage;

  UserMiniModel({required this.id, required this.fullname, this.profileImage});

  factory UserMiniModel.fromJson(Map<String, dynamic> json) {
    return UserMiniModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fullname: json['fullname']?.toString() ?? json['name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'profile_image': profileImage,
      };
}
```

---

## 10. `lib/services/urls.dart` (Pusher + messages)

```dart
class Urls {
  static const _baseUrL = "https://torko.attoexasolutions.com/api";

  static const send_message = "$_baseUrL/messages/send";
  static const get_Message_API = "$_baseUrL/messages";
  static const get_Single_Message_API = "$_baseUrL/single/message";
  static const message_search = "$_baseUrL/search/message";
  static const pusher_auth = "$_baseUrL/broadcasting/auth";
}
```

---

## 11. `lib/views/conversation/conversation_view.dart` (realtime-related)

```dart
// State
late final ChatController chatController;
final messageController = TextEditingController();
final scrollController = ScrollController();
bool _hasInitialized = false;
Map<String, dynamic>? _conversationArgs;

@override
void initState() {
  super.initState();
  chatController = Get.find<ChatController>();
  scrollController.addListener(_onScroll);
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
  final args = Get.arguments;
  if (args != null && args is Map<String, dynamic>) {
    int? toUserId = args['to_user_id'] is int
        ? args['to_user_id']
        : int.tryParse(args['to_user_id']?.toString() ?? '');
    if (toUserId == null) toUserId = args['toUserId'] is int
        ? args['toUserId']
        : int.tryParse(args['toUserId']?.toString() ?? '');
    if (toUserId != null && toUserId > 0) {
      _conversationArgs = args;
      await chatController.initChat(
        toUserId: toUserId,
        receiverName: args['fullname'] ?? args['receiverName'],
        receiverAvatar: args['profile_image'] ?? args['receiverAvatar'],
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(force: true));
      return;
    }
  }
  // Fallback: appController.conversationData
}

@override
void dispose() {
  scrollController.removeListener(_onScroll);
  chatController.clearChat();
  messageController.dispose();
  scrollController.dispose();
  super.dispose();
}

Future<void> _handleSendMessage() async {
  if (messageController.text.trim().isEmpty) return;
  if (chatController.isSending.value) return;
  final success = await chatController.sendMessage(messageController.text.trim());
  if (success) {
    messageController.clear();
    _scrollToBottom(force: true);
  }
}

// Build: Obx(() { ... messageCount = chatController.messages.length; ...
//   return ListView.builder(
//     itemCount: messageCount,
//     itemBuilder: (_, i) => _buildMessageBubble(chatController.messages[i], ...);
//   );
// });
```

---

## 12. `lib/views/messages/messages_view.dart` (realtime-related)

```dart
late final InboxController inboxController;

@override
void initState() {
  super.initState();
  inboxController = Get.find<InboxController>();
  inboxController.loadInboxOnce();
}

// Build: RefreshIndicator(onRefresh: () => inboxController.refresh(), ...
//   Obx(() => _buildBody(...))  // threads, search, etc.
// );
// Tap thread -> Get.toNamed(conversation, arguments: { to_user_id, fullname, ... });
```

---

## 13. Message API usage (realtime flow)

- **Inbox:** `MessageApiService.fetchInboxRows(token)` → build threads.
- **Conversation:** `MessageApiService.fetchConversation(token, toUserId)` → load history.
- **Send:** `MessageApiService.sendMessage(token, toUserId, content)` → returns `MessageModel`.
- **Search:** `MessageApiService.searchMessages(token, keyword)`.

---

## 14. Config summary

| Item | Value |
|------|--------|
| Pusher key | `9df09725d514e737df9a` |
| Cluster | `ap2` |
| Channel | `private-chat.{userId}` |
| Event | `message.sent` |
| Auth | `POST https://torko.attoexasolutions.com/api/broadcasting/auth` |
| Body | `{ "socket_id": "...", "channel_name": "private-chat.{userId}" }` |

---

## 15. File list

| File | Role |
|------|------|
| `lib/services/pusher_service.dart` | Singleton Pusher, init/disconnect, stream, auth, event handling |
| `lib/controllers/chat_controller.dart` | Permanent; stream listener; initChat, loadConversationOnce, sendMessage, handleIncoming |
| `lib/controllers/inbox_controller.dart` | Permanent; stream listener; loadInboxOnce, fetchInbox, handleIncoming |
| `lib/core/bindings/initial_bindings.dart` | Register Chat, Inbox, AppLifecycle; Pusher init when logged in |
| `lib/views/login/login_controller.dart` | After OTP: disconnect → init Pusher |
| `lib/services/logout_service.dart` | Pusher disconnect first; clear Chat/Inbox state |
| `lib/services/app_lifecycle_service.dart` | Resume → Pusher init when logged in |
| `lib/models/message_model.dart` | MessageModel, fromJson, temporary |
| `lib/models/user_mini_model.dart` | UserMiniModel, fromJson |
| `lib/services/urls.dart` | pusher_auth, message endpoints |
| `lib/views/conversation/conversation_view.dart` | ChatController, initChat, send, Obx messages, clearChat on dispose |
| `lib/views/messages/messages_view.dart` | InboxController, loadInboxOnce, refresh |
| `lib/services/message_api_service.dart` | fetchInboxRows, fetchConversation, sendMessage, searchMessages |
| `lib/services/network_caller.dart` | postAuth (Bearer + api_token) for pusher_auth |
