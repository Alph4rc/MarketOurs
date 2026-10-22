import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/pages/settings/permissions_screen.dart';
import 'package:mobile_app/services/app_permissions_service.dart';

void main() {
  testWidgets('shows permission statuses and requests a denied permission', (
    tester,
  ) async {
    final service = _FakePermissionsService({
      AppPermissionKind.notifications: PermissionStatus.granted,
      AppPermissionKind.camera: PermissionStatus.denied,
    });

    await tester.pumpWidget(_buildApp(service));
    await tester.pumpAndSettle();

    expect(find.text('权限管理'), findsOneWidget);
    expect(find.text('已开启 1 / 2 项'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('相机'), findsOneWidget);
    expect(find.text('未开启'), findsOneWidget);

    await tester.tap(find.text('相机'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(service.requested, [AppPermissionKind.camera]);

    // Let the success toast disappear before the test ends.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('已开启 2 / 2 项'), findsOneWidget);
  });
}

Widget _buildApp(AppPermissionsService service) {
  return ProviderScope(
    overrides: [appPermissionsServiceProvider.overrideWithValue(service)],
    child: CupertinoApp(
      locale: const Locale('zh'),
      supportedLocales: const [Locale('zh')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => McThemeData.wrap(
        colors: McColors.light,
        locale: const Locale('zh'),
        child: child!,
      ),
      home: const PermissionsScreen(),
    ),
  );
}

class _FakePermissionsService extends AppPermissionsService {
  _FakePermissionsService(this._statuses);

  final Map<AppPermissionKind, PermissionStatus> _statuses;
  final List<AppPermissionKind> requested = [];

  @override
  bool get isSupported => true;

  @override
  Future<AppPermissionsSnapshot> load() async {
    return AppPermissionsSnapshot(
      permissions: [
        for (final entry in _statuses.entries)
          AppPermissionState(kind: entry.key, status: entry.value),
      ],
    );
  }

  @override
  Future<PermissionStatus> request(AppPermissionKind kind) async {
    requested.add(kind);
    const granted = PermissionStatus.granted;
    _statuses[kind] = granted;
    return granted;
  }
}
