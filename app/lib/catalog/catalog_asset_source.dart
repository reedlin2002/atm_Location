import 'package:flutter/services.dart';

abstract interface class CatalogAssetSource {
  Future<String> loadBundledCatalog();
}

class RootBundleCatalogAssetSource implements CatalogAssetSource {
  const RootBundleCatalogAssetSource();

  static String? _cachedCatalog;

  @override
  Future<String> loadBundledCatalog() async {
    final cached = _cachedCatalog;
    if (cached != null) {
      return cached;
    }
    final catalog = await rootBundle.loadString(
      'assets/catalog/baseline_fixture.json',
    );
    _cachedCatalog = catalog;
    return catalog;
  }
}
