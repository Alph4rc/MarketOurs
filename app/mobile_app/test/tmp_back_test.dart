import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luamris_ui/luamris_ui.dart';

Widget _page(String title, {Widget? child}) {
  return McPageScaffold(
    navigationBarStyle: McNavigationBarStyle.compact,
    title: title,
    child: child ?? const SizedBox(height: 100),
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => _page(
                  'home',
                  child: CupertinoButton(
                    onPressed: () => context.push('/second'),
                    child: const Text('go'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/second', builder: (context, state) => _page('second')),
    ],
  );
}

void main() {
  testWidgets('push from shell branch -> back button works', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      CupertinoApp.router(
        routerConfig: router,
        builder: (context, child) => McThemeData.wrap(
          colors: McColors.light,
          locale: const Locale('zh'),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print('back buttons: ${find.byType(CupertinoNavigationBarBackButton).evaluate().length}');
    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsWidgets);
  });
}
