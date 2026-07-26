import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartupPage extends ConsumerWidget {
  const AppStartupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);
    return startup.when(
      data: (result) => switch (result) {
        AppStartupReady(:final onboardingComplete) when onboardingComplete =>
          const NearbyMapPage(),
        AppStartupReady() => OnboardingPage(
          onFinished: () async {
            await ref.read(onboardingPreferencesProvider).markComplete();
            ref.invalidate(appStartupProvider);
          },
        ),
        AppStartupCatalogFailure() => _CatalogFailure(
          onRetry: () => ref.invalidate(appStartupProvider),
        ),
      },
      error: (error, stackTrace) =>
          _CatalogFailure(onRetry: () => ref.invalidate(appStartupProvider)),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.onFinished,
    this.reviewMode = false,
    super.key,
  });

  final Future<void> Function() onFinished;
  final bool reviewMode;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _finishing = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.onboardingHelpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              localizations.onboardingWelcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(localizations.onboardingSummary),
            const SizedBox(height: 24),
            _InformationTile(
              icon: Icons.my_location,
              title: localizations.onboardingLocationTitle,
              message: localizations.onboardingLocationBody,
            ),
            _InformationTile(
              icon: Icons.dataset_outlined,
              title: localizations.onboardingSourcesTitle,
              message: localizations.onboardingSourcesBody,
            ),
            _InformationTile(
              icon: Icons.privacy_tip_outlined,
              title: localizations.onboardingPrivacyTitle,
              message: localizations.onboardingPrivacyBody,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _finishing ? null : _finish,
              child: Text(
                widget.reviewMode ? localizations.back : localizations.skip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    await widget.onFinished();
    if (mounted) {
      setState(() => _finishing = false);
    }
  }
}

class _InformationTile extends StatelessWidget {
  const _InformationTile({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(message),
    );
  }
}

class _CatalogFailure extends StatelessWidget {
  const _CatalogFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.loadAtmsError),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(localizations.retry)),
          ],
        ),
      ),
    );
  }
}
