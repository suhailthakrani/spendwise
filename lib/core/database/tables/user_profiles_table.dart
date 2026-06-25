import 'package:drift/drift.dart';

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get memberSince => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
