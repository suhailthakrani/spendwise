class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.regionCode = 'US',
    this.currencyCode = 'USD',
    this.avatarUrl,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String regionCode;
  final String currencyCode;
  final String? avatarUrl;
  final DateTime? memberSince;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? regionCode,
    String? currencyCode,
    String? avatarUrl,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      regionCode: regionCode ?? this.regionCode,
      currencyCode: currencyCode ?? this.currencyCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
