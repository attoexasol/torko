/// Utility class for formatting time in inbox threads
class TimeFormatter {
  /// Format time for inbox display
  /// - if < 24h show "h:mm a" or "1h"
  /// - if same week show "Mon"
  /// - else show "dd/MM"
  static String formatInboxTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isToday = now.day == dateTime.day &&
                    now.month == dateTime.month &&
                    now.year == dateTime.year;
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
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm';
    } else if (isThisWeek) {
      // Same week: show day name like "Mon"
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Older: show "dd/MM"
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }
  }
}
