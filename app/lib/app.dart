import 'package:atmfinder/design/app_theme.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';

class AtmFinderApp extends StatelessWidget {
  const AtmFinderApp({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: const Locale('zh', 'TW'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: home ?? const AppStartupPage(),
    );
  }
}
