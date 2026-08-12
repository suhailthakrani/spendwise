import 'package:drift/drift.dart';

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get passwordHash => text().withDefault(const Constant(''))();
  TextColumn get passwordSalt => text().withDefault(const Constant(''))();
  TextColumn get regionCode => text().withDefault(const Constant('US'))();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get memberSince => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
