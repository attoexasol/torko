import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/app/theme/app_colors.dart';
import 'package:torko/presentation/friends/controllers/friends_controller.dart';

class FriendsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FriendsScreen({super.key, this.onBack});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final appController = Get.find<AppController>();
  late FriendsController friendsController;
  final RxString activeTab = 'suggestions'.obs;

  // Mock suggested friends data (exact match from React)
  final List<FriendUser> suggestedFriends = [
    FriendUser(
      id: 'suggest_1',
      name: 'রাফি ইসলাম',
      username: 'rafi_islam',
      location: 'ঢাকা, বাংলাদেশ',
      mutualFriends: 12,
      isOnline: true,
      bio: 'টেক এন্থুসিয়াস্ট | স্টার্টআপ ফাউন্ডার',
    ),
    FriendUser(
      id: 'suggest_2',
      name: 'সাবিহা খান',
      username: 'sabiha_khan',
      location: 'চট্টগ্রাম, বাংলাদেশ',
      mutualFriends: 8,
      isOnline: true,
      bio: 'গ্রাফিক ডিজাইনার | ফটোগ্রাফার',
    ),
    FriendUser(
      id: 'suggest_3',
      name: 'তানভীর আহমেদ',
      username: 'tanvir_ahmed',
      location: 'সিলেট, বাংলাদেশ',
      mutualFriends: 15,
      isOnline: false,
      bio: 'সফটওয়্যার ইঞ্জিনিয়ার | ট্রাভেল লাভার',
    ),
    FriendUser(
      id: 'suggest_4',
      name: 'মাহিয়া তাবাসসুম',
      username: 'mahiya_tabassum',
      location: 'রাজশাহী, বাংলাদেশ',
      mutualFriends: 6,
      isOnline: true,
      bio: 'কন্টেন্ট ক্রিয়েটর | ফুড ব্লগার',
    ),
    FriendUser(
      id: 'suggest_5',
      name: 'আরিফ হোসেন',
      username: 'arif_hossain',
      location: 'খুলনা, বাংলাদেশ',
      mutualFriends: 10,
      isOnline: false,
      bio: 'ডিজিটাল মার্কেটার | এন্ট্রিপ্রেনিউর',
    ),
    FriendUser(
      id: 'suggest_6',
      name: 'নুসরাত জাহান',
      username: 'nusrat_jahan',
      location: 'বরিশাল, বাংলাদেশ',
      mutualFriends: 4,
      isOnline: true,
      bio: 'UI/UX ডিজাইনার | ক্রিয়েটিভ ডিরেক্টর',
    ),
  ];

  @override
  void initState() {
    super.initState();
    friendsController = Get.put(FriendsController(), permanent: false);
  }

  bool get isDark => appController.isDarkMode;
  bool get isBn => appController.language == AppLanguage.bn;

  Map<String, String> get translations => {
        'title': isBn ? 'বন্ধুরা' : 'Friends',
        'friends': isBn ? 'বন্ধুরা' : 'Friends',
        'requests': isBn ? 'রিকোয়েস্ট' : 'Requests',
        'sent': isBn ? 'পাঠানো' : 'Sent',
        'suggestions': isBn ? 'সাজেশন' : 'Suggestions',
        'noFriends': isBn ? 'এখনো কোনো বন্ধু নেই' : 'No friends yet',
        'noRequests': isBn ? 'কোনো রিকোয়েস্ট নেই' : 'No requests',
        'noSent': isBn ? 'কোনো রিকোয়েস্ট পাঠানো হয়নি' : 'No sent requests',
        'accept': isBn ? 'গ্রহণ করুন' : 'Accept',
        'decline': isBn ? 'প্রত্যাখ্যান' : 'Decline',
        'cancel': isBn ? 'বাতিল করুন' : 'Cancel',
        'remove': isBn ? 'সরান' : 'Remove',
        'addFriend': isBn ? 'বন্ধু যোগ করুন' : 'Add Friend',
        'requestSent': isBn ? 'রিকোয়েস্ট পাঠানো হয়েছে' : 'Request Sent',
        'mutualFriends': isBn ? 'মিউচুয়াল বন্ধু' : 'mutual friends',
        'online': isBn ? 'অনলাইন' : 'Online',
        'pending': isBn ? 'অপেক্ষারত' : 'Pending',
        'alreadyFriends': isBn ? 'ইতিমধ্যে বন্ধু' : 'Already Friends',
        'addDemoRequests': isBn ? '📩 ডেমো রিকোয়েস্ট যোগ করুন' : '📩 Add Demo Requests',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF052029) : const Color(0xFFf5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            _buildHeader(),
            // Content
            Expanded(
              child: Obx(() => _buildContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF052029).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe5e5e5),
          ),
        ),
      ),
      child: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: isDark ? Colors.white : const Color(0xFF0f1419),
                  onPressed: widget.onBack ?? () => Get.back(),
                ),
                Expanded(
                  child: Text(
                    translations['title']!,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0f1419),
                    ),
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${friendsController.friends.length}${isBn ? ' জন' : ''}',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFB8DED6) : const Color(0xFF536471),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          // Tabs
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildTabButton('suggestions', Icons.person_add, translations['suggestions']!),
          const SizedBox(width: 8),
          _buildTabButton('friends', Icons.people, translations['friends']!),
          const SizedBox(width: 8),
          Obx(() => _buildTabButton(
                'requests',
                Icons.person_add_alt_1,
                translations['requests']!,
                badge: friendsController.pendingCount > 0
                    ? friendsController.pendingCount
                    : null,
              )),
          const SizedBox(width: 8),
          _buildTabButton('sent', Icons.access_time, translations['sent']!),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, IconData icon, String label, {int? badge}) {
    return Obx(() {
      final isActive = activeTab.value == tab;
      return GestureDetector(
        onTap: () => activeTab.value = tab,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFFd97757) : const Color(0xFF166534))
                : (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : (isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786))),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  color: isActive ? Colors.white : (isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786)),
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFd97757) : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    if (activeTab.value == 'friends') {
      return _buildFriendsTab();
    } else if (activeTab.value == 'requests') {
      return _buildRequestsTab();
    } else if (activeTab.value == 'sent') {
      return _buildSentTab();
    } else {
      return _buildSuggestionsTab();
    }
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      if (friendsController.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 64,
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
              ),
              const SizedBox(height: 16),
              Text(
                translations['noFriends']!,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friendsController.friends.length,
        itemBuilder: (context, index) {
          final friend = friendsController.friends[index];
          return _FriendCard(
            user: friend,
            isDark: isDark,
            isBn: isBn,
            onRemove: () => friendsController.removeFriend(friend.id),
            translations: translations,
          );
        },
      );
    });
  }

  Widget _buildRequestsTab() {
    return Obx(() {
      final pending = friendsController.pendingRequests;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Demo button
          if (friendsController.friendRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    friendsController.addDemoFriendRequests();
                    Get.snackbar(
                      isBn ? 'সফল' : 'Success',
                      isBn ? 'ডেমো রিকোয়েস্ট যোগ করা হয়েছে' : 'Demo requests added',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFd97757) : const Color(0xFF166534),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    translations['addDemoRequests']!,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          if (pending.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1,
                    size: 64,
                    color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translations['noRequests']!,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                    ),
                  ),
                ],
              ),
            )
          else
            ...pending.asMap().entries.map((entry) {
              final index = entry.key;
              final request = entry.value;
              return _RequestCard(
                request: request,
                isDark: isDark,
                isBn: isBn,
                onAccept: () => friendsController.acceptFriendRequest(request.id),
                onDecline: () => friendsController.declineFriendRequest(request.id),
                translations: translations,
                index: index,
              );
            }),
        ],
      );
    });
  }

  Widget _buildSentTab() {
    return Obx(() {
      final pending = friendsController.pendingSentRequests;

      if (pending.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 64,
                color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
              ),
              const SizedBox(height: 16),
              Text(
                translations['noSent']!,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        itemBuilder: (context, index) {
          final request = pending[index];
          return _SentRequestCard(
            request: request,
            isDark: isDark,
            isBn: isBn,
            onCancel: () => friendsController.cancelFriendRequest(request.id),
            translations: translations,
            index: index,
          );
        },
      );
    });
  }

  Widget _buildSuggestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestedFriends.length,
      itemBuilder: (context, index) {
        final user = suggestedFriends[index];
        return Obx(() {
          final isAlreadyFriend = friendsController.isFriend(user.id);
          final hasSent = friendsController.hasSentRequest(user.id);
          return _SuggestionCard(
            user: user,
            isDark: isDark,
            isBn: isBn,
            isAlreadyFriend: isAlreadyFriend,
            hasSent: hasSent,
            onAddFriend: () => friendsController.sendFriendRequest(user.id, user),
            translations: translations,
            index: index,
          );
        });
      },
    );
  }
}

// Friend Card Widget
class _FriendCard extends StatelessWidget {
  final FriendUser user;
  final bool isDark;
  final bool isBn;
  final VoidCallback onRemove;
  final Map<String, String> translations;

  const _FriendCard({
    required this.user,
    required this.isDark,
    required this.isBn,
    required this.onRemove,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildAvatar(user.name, user.avatar, 48, user.isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0f1419),
                  ),
                ),
                if (user.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.location!,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                    ),
                  ),
                ],
                if (user.mutualFriends != null && user.mutualFriends! > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${user.mutualFriends} ${translations['mutualFriends']!}',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.person_remove, size: 20),
              color: isDark
                  ? const Color(0xFFB8DED6)
                  : const Color(0xFF657786),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatar, double size, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFd97757),
            shape: BoxShape.circle,
          ),
          child: avatar != null && avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(name, size),
                  ),
                )
              : _buildInitials(name, size),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Request Card Widget
class _RequestCard extends StatelessWidget {
  final FriendRequest request;
  final bool isDark;
  final bool isBn;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final Map<String, String> translations;
  final int index;

  const _RequestCard({
    required this.request,
    required this.isDark,
    required this.isBn,
    required this.onAccept,
    required this.onDecline,
    required this.translations,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(request.id),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(request.from.name, request.from.avatar, 48, request.from.isOnline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.from.name,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0f1419),
                        ),
                      ),
                      if (request.from.location != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          request.from.location!,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                          ),
                        ),
                      ],
                      if (request.from.mutualFriends != null && request.from.mutualFriends! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${request.from.mutualFriends} ${translations['mutualFriends']!}',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      translations['accept']!,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFd97757) : const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(
                      translations['decline']!,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatar, double size, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFd97757),
            shape: BoxShape.circle,
          ),
          child: avatar != null && avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(name, size),
                  ),
                )
              : _buildInitials(name, size),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Sent Request Card Widget
class _SentRequestCard extends StatelessWidget {
  final FriendRequest request;
  final bool isDark;
  final bool isBn;
  final VoidCallback onCancel;
  final Map<String, String> translations;
  final int index;

  const _SentRequestCard({
    required this.request,
    required this.isDark,
    required this.isBn,
    required this.onCancel,
    required this.translations,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(request.id),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildAvatar(request.from.name, request.from.avatar, 48, false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.from.name,
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0f1419),
                    ),
                  ),
                  if (request.from.location != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.from.location!,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        translations['pending']!,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786),
                side: BorderSide(
                  color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFd0d0d0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                translations['cancel']!,
                style: GoogleFonts.notoSansBengali(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatar, double size, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFd97757),
            shape: BoxShape.circle,
          ),
          child: avatar != null && avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(name, size),
                  ),
                )
              : _buildInitials(name, size),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Suggestion Card Widget
class _SuggestionCard extends StatelessWidget {
  final FriendUser user;
  final bool isDark;
  final bool isBn;
  final bool isAlreadyFriend;
  final bool hasSent;
  final VoidCallback onAddFriend;
  final Map<String, String> translations;
  final int index;

  const _SuggestionCard({
    required this.user,
    required this.isDark,
    required this.isBn,
    required this.isAlreadyFriend,
    required this.hasSent,
    required this.onAddFriend,
    required this.translations,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(user.id),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFe0e0e0),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(user.name, user.avatar, 56, user.isOnline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0f1419),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                        ),
                      ),
                      if (user.location != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '📍 ${user.location!}',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFB8DED6).withOpacity(0.6) : const Color(0xFF657786),
                          ),
                        ),
                      ],
                      if (user.bio != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.bio!,
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFB8DED6).withOpacity(0.7) : const Color(0xFF657786),
                          ),
                        ),
                      ],
                      if (user.mutualFriends != null && user.mutualFriends! > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 12,
                              color: isDark ? const Color(0xFFd97757) : const Color(0xFF166534),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.mutualFriends} ${translations['mutualFriends']!}',
                              style: GoogleFonts.notoSansBengali(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFd97757) : const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isAlreadyFriend || hasSent) ? null : onAddFriend,
                icon: Icon(
                  isAlreadyFriend
                      ? Icons.check_circle
                      : hasSent
                          ? Icons.access_time
                          : Icons.person_add,
                  size: 16,
                ),
                label: Text(
                  isAlreadyFriend
                      ? translations['alreadyFriends']!
                      : hasSent
                          ? translations['requestSent']!
                          : translations['addFriend']!,
                  style: GoogleFonts.notoSansBengali(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyFriend
                      ? (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0))
                      : hasSent
                          ? (isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0))
                          : (isDark ? const Color(0xFFd97757) : const Color(0xFF166534)),
                  foregroundColor: isAlreadyFriend || hasSent
                      ? (isDark ? const Color(0xFFB8DED6) : const Color(0xFF657786))
                      : Colors.white,
                  disabledBackgroundColor: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFf0f0f0),
                  disabledForegroundColor: isDark ? const Color(0xFFB8DED6).withOpacity(0.5) : const Color(0xFF9ca3af),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: hasSent
                        ? BorderSide(
                            color: isDark ? const Color(0xFFd97757) : const Color(0xFF166534),
                            width: 1,
                          )
                        : BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatar, double size, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFd97757),
            shape: BoxShape.circle,
          ),
          child: avatar != null && avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(name, size),
                  ),
                )
              : _buildInitials(name, size),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name, double size) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
