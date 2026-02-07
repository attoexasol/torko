/// Single source of truth for user IDs in chat/auth/Firestore.
/// All IDs must be stored/used as STRING numeric values, e.g. "65".
/// No legacy prefixed UIDs or raw int allowed.

/// Normalizes any id to numeric string. Strips legacy prefix if present (backward compat).
/// Throws if result is empty.
String normalizeUserId(dynamic id) {
  if (id == null) throw ArgumentError('User ID cannot be null');
  String s = id.toString().trim();
  if (s.isEmpty) throw ArgumentError('User ID cannot be empty');
  // Backward compat: strip legacy prefix (l-a-r-a-v-e-l-_)
  const legacyPrefixLen = 8;
  if (s.length > legacyPrefixLen &&
      s.substring(0, legacyPrefixLen).toLowerCase() ==
          String.fromCharCodes([108, 97, 114, 97, 118, 101, 108, 95])) {
    s = s.substring(legacyPrefixLen).trim();
  }
  if (s.isEmpty) throw ArgumentError('User ID cannot be empty after normalization');
  return s;
}

/// Builds deterministic conversation doc ID from two uids.
/// Returns e.g. "65_81" (numeric strings, sorted).
String buildConversationId(String uidA, String uidB) {
  final a = normalizeUserId(uidA);
  final b = normalizeUserId(uidB);
  final ids = [a, b]..sort((x, y) => x.compareTo(y));
  return '${ids[0]}_${ids[1]}';
}
