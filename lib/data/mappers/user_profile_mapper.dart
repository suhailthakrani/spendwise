import '../../core/database/app_database.dart';
import '../models/user_profile.dart';

abstract final class UserProfileMapper {
  static UserProfile fromRow(UserProfileRow row) {
    return UserProfile(
      id: row.id,
      name: row.name,
      email: row.email,
      regionCode: row.regionCode,
      currencyCode: row.currencyCode,
      avatarUrl: row.avatarUrl,
      googleId: row.googleId,
      hasLocalPassword: row.passwordHash.isNotEmpty,
      memberSince: row.memberSince,
    );
  }
}
