import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:taxi_client_manual/core/shared/account_status.dart';
import 'package:taxi_client_manual/features/session/domain/session_repository.dart';
import 'package:taxi_client_manual/features/session/presentation/session_cubit.dart';
import 'package:taxi_client_manual/features/session/presentation/session_state.dart';

// ═══════════════════════════════════════════
// Fake Repository
// ═══════════════════════════════════════════
class FakeSessionRepository implements SessionRepository {
  SessionInfo? sessionResult;
  bool shouldThrow = false;
  bool signOutCalled = false;
  bool startNotifCalled = false;
  bool stopNotifCalled = false;

  @override
  bool get hasCurrentUser => sessionResult != null;

  @override
  Future<SessionInfo?> checkSession() async {
    if (shouldThrow) throw Exception('error');
    return sessionResult;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  void startNotificationServices() {
    startNotifCalled = true;
  }

  @override
  void stopNotificationServices() {
    stopNotifCalled = true;
  }
}

void main() {
  late FakeSessionRepository repo;

  setUp(() {
    repo = FakeSessionRepository();
  });

  group('SessionCubit.checkSession', () {
    blocTest<SessionCubit, SessionState>(
      'لا يوجد مستخدم → Unauthenticated',
      build: () {
        repo.sessionResult = null;
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<SessionLoading>(), isA<SessionUnauthenticated>()],
    );

    blocTest<SessionCubit, SessionState>(
      'حساب active → Authenticated + يشغل الإشعارات',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-1',
          name: 'أحمد',
          accountStatus: AccountStatus.active,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionAuthenticated>()
            .having((s) => s.uid, 'uid', 'u-1')
            .having((s) => s.name, 'name', 'أحمد'),
      ],
      verify: (_) {
        expect(repo.startNotifCalled, true);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'حساب blocked → Blocked + يسجل خروج',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-2',
          name: 'خالد',
          accountStatus: AccountStatus.blocked,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionBlocked>().having(
          (s) => s.status,
          'status',
          AccountStatus.blocked,
        ),
      ],
      verify: (_) {
        expect(repo.signOutCalled, true);
        expect(repo.stopNotifCalled, true);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'حساب suspended → Blocked + يسجل خروج',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-3',
          name: 'سعد',
          accountStatus: AccountStatus.suspended,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionBlocked>().having(
          (s) => s.status,
          'status',
          AccountStatus.suspended,
        ),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'حساب disabled → Blocked + يسجل خروج',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-4',
          name: 'علي',
          accountStatus: AccountStatus.disabled,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionBlocked>().having(
          (s) => s.status,
          'status',
          AccountStatus.disabled,
        ),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'حساب pending → PendingApproval',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-5',
          name: 'فهد',
          accountStatus: AccountStatus.pending,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<SessionLoading>(), isA<SessionPendingApproval>()],
    );

    blocTest<SessionCubit, SessionState>(
      'حساب rejected → Rejected + يسجل خروج',
      build: () {
        repo.sessionResult = const SessionInfo(
          uid: 'u-6',
          name: 'ماجد',
          accountStatus: AccountStatus.rejected,
        );
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<SessionLoading>(), isA<SessionRejected>()],
      verify: (_) {
        expect(repo.signOutCalled, true);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'خطأ → Unauthenticated',
      build: () {
        repo.shouldThrow = true;
        return SessionCubit(repo);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<SessionLoading>(), isA<SessionUnauthenticated>()],
    );
  });

  group('SessionCubit.signOut', () {
    blocTest<SessionCubit, SessionState>(
      'تسجيل خروج → Unauthenticated + يوقف الإشعارات',
      build: () => SessionCubit(repo),
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<SessionUnauthenticated>()],
      verify: (_) {
        expect(repo.signOutCalled, true);
        expect(repo.stopNotifCalled, true);
      },
    );
  });
}
