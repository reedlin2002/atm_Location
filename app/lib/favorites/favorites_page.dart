import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final favorites = ref.watch(favoritesProvider);
    final bankPreferences =
        (ref.watch(userSettingsProvider).value ?? const UserSettings())
            .bankPreferences;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.favoritesTitle)),
      body: favorites.when(
        data: (values) {
          if (values.isEmpty) {
            return Center(child: Text(localizations.favoritesTitle));
          }
          return ListView.separated(
            itemCount: values.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final favorite = values[index];
              return ListTile(
                key: ValueKey('favorite-site-${favorite.site.id}'),
                leading: Icon(
                  favorite.retired ? Icons.warning_amber : Icons.favorite,
                ),
                title: Text(favorite.site.institutionName),
                subtitle: Text(
                  favorite.retired
                      ? '${favorite.site.placeName}\n'
                            '${localizations.retiredFavoriteWarning}'
                      : '${favorite.site.placeName}\n'
                            '${favorite.site.displayAddress}',
                ),
                isThreeLine: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AtmDetailPage(
                      site: favorite.site,
                      retired: favorite.retired,
                      bankPreferences: bankPreferences,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(localizations.loadAtmsError)),
      ),
    );
  }
}
