/// Built-in emoji avatars (KharchaBook-style) users can pick for their profile.
abstract final class PresetAvatars {
  /// Stored in [UserProfile.avatarUrl] so [ProfileAvatar] can resolve them.
  static const prefix = 'emoji:';

  /// Curated set — expressive, gender-diverse, and common everyday picks.
  static const List<String> all = [
    '😀',
    '😄',
    '😁',
    '😎',
    '🤩',
    '😊',
    '🙂',
    '😉',
    '😌',
    '🤗',
    '🥳',
    '😇',
    '🤓',
    '🧐',
    '🤠',
    '👻',
    '🤖',
    '👽',
    '🐱',
    '🐶',
    '🐼',
    '🦊',
    '🐯',
    '🦁',
    '🐸',
    '🐵',
    '🦄',
    '🐝',
    '🌸',
    '🌟',
    '🔥',
    '⚡',
    '💎',
    '🎯',
    '🚀',
    '🎮',
    '🎧',
    '☕',
    '🍕',
    '🍔',
    '🍩',
    '⚽',
    '🏀',
    '🎨',
    '📚',
    '💼',
    '🏠',
    '🌈',
  ];

  static bool isPreset(String? path) => decode(path) != null;

  static String encode(String emoji) {
    final value = emoji.trim();
    if (value.startsWith(prefix)) return value;
    return '$prefix$value';
  }

  /// Returns the emoji character, or null if [path] is not a preset avatar.
  static String? decode(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith(prefix)) {
      final emoji = value.substring(prefix.length).trim();
      return all.contains(emoji) ? emoji : null;
    }
    // Backward-compatible: bare emoji stored without prefix.
    return all.contains(value) ? value : null;
  }
}
