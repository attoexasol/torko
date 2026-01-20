import 'message_row_model.dart';

/// Model for a grouped conversation thread in inbox
class InboxThreadModel {
  final int otherUserId;
  final String otherName;
  final String? otherAvatar;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final MessageRowModel lastRow;

  InboxThreadModel({
    required this.otherUserId,
    required this.otherName,
    this.otherAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
    required this.lastRow,
  });

  /// Format time for display
  /// - if < 24h show "h:mm a" or "1h"
  /// - if same week show "Mon"
  /// - else show "dd/MM"
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    final isToday = now.day == lastTime.day &&
                    now.month == lastTime.month &&
                    now.year == lastTime.year;
    final isThisWeek = difference.inDays < 7 && !isToday;

    if (isToday) {
      // Today: show time like "2:30 PM" or "1h"
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'now';
        }
        return '${difference.inMinutes}m';
      }
      // Show time like "2:30 PM"
      final hour = lastTime.hour > 12 ? lastTime.hour - 12 : (lastTime.hour == 0 ? 12 : lastTime.hour);
      final minute = lastTime.minute.toString().padLeft(2, '0');
      final amPm = lastTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm';
    } else if (isThisWeek) {
      // Same week: show day name like "Mon"
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[lastTime.weekday - 1];
    } else {
      // Older: show "dd/MM"
      return '${lastTime.day.toString().padLeft(2, '0')}/${lastTime.month.toString().padLeft(2, '0')}';
    }
  }
}
