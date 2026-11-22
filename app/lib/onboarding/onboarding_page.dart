import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/design/brand_mark.dart';
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
      loading: () => const BrandedLoadingPage(),
    );
  }
}

/// 啟動時載入內建 ATM 資料的品牌畫面；背景色與 Android 系統 splash 相同。
class BrandedLoadingPage extends StatelessWidget {
  const BrandedLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandMark(size: 128),
                      const SizedBox(height: 20),
                      Text(
                        localizations.appTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        localizations.loadingTagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 160,
                        child: LinearProgressIndicator(
                          semanticsLabel: localizations.loadingCatalog,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations.loadingCatalog,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
              child: Text(
                localizations.loadingSourceNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: widget.reviewMode
          ? AppBar(title: Text(localizations.onboardingHelpTitle))
          : null,
      body: SafeArea(
        top: widget.reviewMode,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: colors.primaryContainer.withValues(alpha: 0.45),
              padding: EdgeInsets.fromLTRB(
                24,
                widget.reviewMode
                    ? 24
                    : 48 + MediaQuery.paddingOf(context).top,
                24,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(size: 88),
                  const SizedBox(height: 16),
                  Text(
                    localizations.onboardingWelcome,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizations.onboardingSummary,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  _InformationTile(
                    icon: Icons.location_on_outlined,
                    title: localizations.onboardingLocationTitle,
                    message: localizations.onboardingLocationBody,
                  ),
                  const SizedBox(height: 12),
                  _InformationTile(
                    icon: Icons.description_outlined,
                    title: localizations.onboardingSourcesTitle,
                    message: localizations.onboardingSourcesBody,
                  ),
                  const SizedBox(height: 12),
                  _InformationTile(
                    icon: Icons.verified_user_outlined,
                    title: localizations.onboardingPrivacyTitle,
                    message: localizations.onboardingPrivacyBody,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _finishing ? null : _finish,
                child: Text(
                  widget.reviewMode
                      ? localizations.back
                      : localizations.onboardingStart,
                ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.primary,
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
