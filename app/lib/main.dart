import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'core/api/router.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FarraxApp(),
    ),
  );
}

class FarraxApp extends ConsumerWidget {
  const FarraxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final Locale locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Farrax',
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ga')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
