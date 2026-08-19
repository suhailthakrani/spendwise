class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.regionCode = 'US',
    this.currencyCode = 'USD',
    this.avatarUrl,
    this.googleId,
    this.hasLocalPassword = true,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String regionCode;
  final String currencyCode;
  final String? avatarUrl;
  final String? googleId;
  final bool hasLocalPassword;
  final DateTime? memberSince;

  bool get isGoogleLinked => googleId != null && googleId!.isNotEmpty;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? regionCode,
    String? currencyCode,
    String? avatarUrl,
    String? googleId,
    bool? hasLocalPassword,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      regionCode: regionCode ?? this.regionCode,
      currencyCode: currencyCode ?? this.currencyCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      googleId: googleId ?? this.googleId,
      hasLocalPassword: hasLocalPassword ?? this.hasLocalPassword,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
