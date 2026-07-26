import 'package:flutter/services.dart';

abstract interface class CatalogAssetSource {
  Future<String> loadBundledCatalog();
}

class RootBundleCatalogAssetSource implements CatalogAssetSource {
  const RootBundleCatalogAssetSource({
    this.assetPath = 'assets/catalog/baseline_catalog.json',
  });

  final String assetPath;

  @override
  Future<String> loadBundledCatalog() => rootBundle.loadString(assetPath);
}
