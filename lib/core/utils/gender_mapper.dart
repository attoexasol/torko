/// Utility to map Flutter gender values to backend API values
/// 
/// Backend expects: male, female, others, "Prefer not to say"
/// Flutter UI uses: male, female, other, prefer-not-to-say
class GenderMapper {
  /// Map Flutter gender value to backend API value
  /// 
  /// [flutterValue] - Gender value from Flutter UI
  /// Returns backend-compatible gender value
  static String mapToBackend(String flutterValue) {
    switch (flutterValue.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'other':
        return 'others'; // Backend expects "others" not "other"
      case 'prefer-not-to-say':
      case 'prefernottosay':
      case 'prefer_not_to_say':
        return 'Prefer not to say'; // Backend expects exact string with spaces
      default:
        // If already in backend format, return as-is
        if (flutterValue == 'others' || flutterValue == 'Prefer not to say') {
          return flutterValue;
        }
        // Default fallback
        return flutterValue;
    }
  }

  /// Map backend gender value to Flutter UI value
  /// 
  /// [backendValue] - Gender value from backend API
  /// Returns Flutter UI-compatible gender value
  static String mapToFlutter(String backendValue) {
    switch (backendValue.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'others':
        return 'other'; // Flutter UI uses "other"
      case 'prefer not to say':
        return 'prefer-not-to-say'; // Flutter UI uses kebab-case
      default:
        return backendValue;
    }
  }
}
