import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/design/brand_mark.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 政府資料開放授權條款第1版「顯名聲明」所需的一筆資料集。
///
/// 提供機關以政府資料開放平臺登記為準。更新內建資料時，一併更新年份
/// （見 scripts/update-baseline-catalog.ps1）。
class OpenDataAttribution {
  const OpenDataAttribution({
    required this.agency,
    required this.year,
    required this.dataset,
    required this.url,
  });

  final String agency;
  final int year;
  final String dataset;
  final String url;
}

const openDataAttributions = <OpenDataAttribution>[
  OpenDataAttribution(
    agency: '中央銀行',
    year: 2026,
    dataset: '金融機構ATM位置查詢一覽表',
    url: 'https://data.gov.tw/dataset/24333',
  ),
  OpenDataAttribution(
    agency: '數位發展部',
    year: 2025,
    dataset: '114年發放現金ATM裝設地點明細',
    url: 'https://data.gov.tw/dataset/175482',
  ),
  OpenDataAttribution(
    agency: '中華郵政股份有限公司',
    year: 2026,
    dataset: '全國郵局ATM分佈',
    url: 'https://data.gov.tw/dataset/6121',
  ),
  OpenDataAttribution(
    agency: '金融監督管理委員會銀行局',
    year: 2026,
    dataset: '可供視障民眾使用之ATM設置地點資訊',
    url: 'https://data.gov.tw/dataset/73189',
  ),
  OpenDataAttribution(
    agency: '金融監督管理委員會銀行局',
    year: 2026,
    dataset: '可供使用輪椅民眾操作之ATM設置地點資訊',
    url: 'https://data.gov.tw/dataset/73188',
  ),
];

const openDataLicenseUrl = 'https://data.gov.tw/license';

class DataSourcesPage extends ConsumerWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final datasetVersion = ref
        .watch(catalogSnapshotProvider)
        .value
        ?.datasetVersion;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.dataSourcesTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                const BrandMark(size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.appTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (datasetVersion != null)
                        Text(
                          localizations.dataSourcesDatasetVersion(
                            datasetVersion,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              color: colors.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.dataSourcesNotOfficial,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text(
              localizations.dataSourcesListTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.primary,
              ),
            ),
          ),
          for (final attribution in openDataAttributions)
            ListTile(
              key: ValueKey('open-data-${attribution.url}'),
              title: Text(attribution.dataset),
              subtitle: Text('${attribution.agency}・${attribution.year}'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _open(context, ref, attribution.url),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.dataSourcesLicenseStatement,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey('open-data-license'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _open(context, ref, openDataLicenseUrl),
                      child: Text(localizations.dataSourcesLicenseLink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    var opened = false;
    try {
      opened = await ref
          .read(externalActionGatewayProvider)
          .openUri(Uri.parse(url));
    } on Object {
      opened = false;
    }
    if (opened || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).externalActionUnavailable),
      ),
    );
  }
}
