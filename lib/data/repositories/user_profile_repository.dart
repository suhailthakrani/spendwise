import '../../core/database/app_database.dart';
import '../mappers/user_profile_mapper.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;

  Stream<UserProfile?> watchProfile() {
    return _db.select(_db.userProfiles).watchSingleOrNull().map(
          (row) => row == null ? null : UserProfileMapper.fromRow(row),
        );
  }
}
