import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/data/models/google_identity.dart';
import 'package:spendwise/data/repositories/user_profile_repository.dart';

void main() {
  test('Google sign-up creates a local profile and signs back in', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = UserProfileRepository(db);

    const identity = GoogleIdentity(
      id: 'gid-1',
      email: 'ada@gmail.com',
      displayName: 'Ada Lovelace',
      photoUrl: 'https://example.com/ada.png',
    );

    final created = await repo.signInOrSignUpWithGoogle(
      identity: identity,
      regionCode: 'PK',
      currencyCode: 'PKR',
    );

    expect(created.email, 'ada@gmail.com');
    expect(created.name, 'Ada Lovelace');
    expect(created.googleId, 'gid-1');
    expect(created.hasLocalPassword, isFalse);
    expect(created.regionCode, 'PK');
    expect(created.currencyCode, 'PKR');
    expect(created.avatarUrl, 'https://example.com/ada.png');

    final again = await repo.signInOrSignUpWithGoogle(
      identity: identity,
      regionCode: 'US',
      currencyCode: 'USD',
    );
    expect(again.id, created.id);
    expect(again.regionCode, 'PK');
  });

  test('password sign-in is rejected for Google-only accounts', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = UserProfileRepository(db);

    await repo.signInOrSignUpWithGoogle(
      identity: const GoogleIdentity(
        id: 'gid-2',
        email: 'linus@gmail.com',
        displayName: 'Linus',
      ),
      regionCode: 'US',
      currencyCode: 'USD',
    );

    expect(
      () => repo.signIn(email: 'linus@gmail.com', password: 'secret1'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Continue with Google'),
        ),
      ),
    );
  });

  test('Google sign-in links an existing email account', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = UserProfileRepository(db);

    final local = await repo.signUp(
      name: 'Ada',
      email: 'ada@gmail.com',
      password: 'secret1',
      regionCode: 'US',
      currencyCode: 'USD',
    );

    final linked = await repo.signInOrSignUpWithGoogle(
      identity: const GoogleIdentity(
        id: 'gid-3',
        email: 'ada@gmail.com',
        displayName: 'Ada Google',
      ),
      regionCode: 'PK',
      currencyCode: 'PKR',
    );

    expect(linked.id, local.id);
    expect(linked.googleId, 'gid-3');
    expect(linked.hasLocalPassword, isTrue);
    expect(linked.name, 'Ada');
  });
}
