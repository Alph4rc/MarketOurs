import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalCupertinoLocalizations;
import 'package:feedback_sdk/feedback_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'services/push_notification_service.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.setLocale(PlatformDispatcher.instance.locale.languageCode);

  // 反馈 SDK 初始化（匿名反馈中心）。MarketOurs 无运行时学校概念，固定西建大 slug。
  await FeedbackSdk.init(
    FeedbackConfig(
      baseUrl: 'http://feedbackapi.luckyfishes.site', // TODO: 后端上 TLS 后换 https
      appName: 'lumalis',
      school: 'xauat',
    ),
  );

  runApp(const ProviderScope(child: MarketOursApp()));
}

class MarketOursApp extends ConsumerWidget {
  const MarketOursApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final appLocale = ref.watch(localeNotifierProvider);

    ref.listen(appRouterProvider, (_, next) {
      PushNotificationService.instance.initialize(router: next);
    });
    PushNotificationService.instance.initialize(router: router);

    final brightness =
        themeMode.forcedBrightness ?? MediaQuery.platformBrightnessOf(context);
    final colors = brightness == Brightness.dark
        ? McColors.dark
        : McColors.light;

    return CupertinoApp.router(
      // `build` runs above the app's Localizations widget, so looking up
      // AppLocalizations with this context would always return null during
      // the initial build. Resolve the localized title inside CupertinoApp's
      // localization scope instead.
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: appLocale,
      supportedLocales: supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return McThemeData.wrap(
          colors: colors,
          locale: appLocale,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(platformBrightness: brightness),
            child: child!,
          ),
        );
      },
      theme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: colors.primary,
        scaffoldBackgroundColor: colors.background,
        barBackgroundColor: colors.background,
        textTheme: CupertinoTextThemeData(
          primaryColor: colors.primary,
          textStyle: TextStyle(
            color: colors.foreground,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
