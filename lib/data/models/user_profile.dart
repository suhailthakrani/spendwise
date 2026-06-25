class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? memberSince;
}
