import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SharePayload {
  const SharePayload({required this.text, required this.publicUrl});

  final String text;
  final Uri publicUrl;
}

enum ExternalActionOutcome { launched, unavailable, copiedFallback }

abstract interface class ExternalActionGateway {
  Future<bool> openUri(Uri uri);

  Future<bool> share(SharePayload payload);

  Future<void> copyText(String value);
}

class PlatformExternalActionGateway implements ExternalActionGateway {
  const PlatformExternalActionGateway();

  @override
  Future<bool> openUri(Uri uri) async {
    if (!await canLaunchUrl(uri)) {
      return false;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<bool> share(SharePayload payload) async {
    final result = await SharePlus.instance.share(
      ShareParams(text: payload.text),
    );
    return result.status != ShareResultStatus.unavailable;
  }

  @override
  Future<void> copyText(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }
}

class ExternalActionsController {
  const ExternalActionsController({
    required this.gateway,
    required this.payloads,
  });

  final ExternalActionGateway gateway;
  final AtmExternalPayloadBuilder payloads;

  Future<ExternalActionOutcome> navigate(AtmSite site) async {
    try {
      return await gateway.openUri(payloads.navigation(site))
          ? ExternalActionOutcome.launched
          : ExternalActionOutcome.unavailable;
    } on Object {
      return ExternalActionOutcome.unavailable;
    }
  }

  Future<ExternalActionOutcome> shareAtm(AtmSite site) async {
    try {
      return await gateway.share(payloads.share(site))
          ? ExternalActionOutcome.launched
          : ExternalActionOutcome.unavailable;
    } on Object {
      return ExternalActionOutcome.unavailable;
    }
  }

  Future<ExternalActionOutcome> reportAtm(
    AtmSite site, {
    required String datasetVersion,
  }) {
    return _openEmail(payloads.reportAtm(site, datasetVersion: datasetVersion));
  }

  Future<ExternalActionOutcome> generalFeedback() {
    return _openEmail(payloads.generalFeedback());
  }

  Future<ExternalActionOutcome> _openEmail(Uri uri) async {
    try {
      if (await gateway.openUri(uri)) {
        return ExternalActionOutcome.launched;
      }
    } on Object {
      // Continue to the recoverable copy fallback.
    }
    await gateway.copyText(payloads.supportEmail);
    return ExternalActionOutcome.copiedFallback;
  }
}

class AtmExternalPayloadBuilder {
  const AtmExternalPayloadBuilder({
    required this.supportEmail,
    required this.appVersion,
  });

  final String supportEmail;
  final String appVersion;

  Uri navigation(AtmSite site) {
    final position = site.position;
    if (position == null) {
      throw ArgumentError.value(site.id, 'site', 'ATM has no coordinate');
    }
    final coordinate = '${position.latitude},${position.longitude}';
    return Uri(
      scheme: 'geo',
      path: coordinate,
      queryParameters: {
        'q': '$coordinate (${site.placeName}，${site.displayAddress})',
      },
    );
  }

  SharePayload share(AtmSite site) {
    final position = site.position;
    if (position == null) {
      throw ArgumentError.value(site.id, 'site', 'ATM has no coordinate');
    }
    final publicUrl = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${position.latitude},${position.longitude}',
    });
    return SharePayload(
      publicUrl: publicUrl,
      text:
          '${site.institutionName} ${site.placeName}\n'
          '${site.displayAddress}\n$publicUrl',
    );
  }

  Uri reportAtm(AtmSite site, {required String datasetVersion}) {
    return Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'ATM 資料回報：${site.placeName}',
        'body':
            '請描述問題：\n\n'
            'ATM stable ID：${site.id}\n'
            '銀行：${site.institutionName}（${site.institutionCode}）\n'
            '場所：${site.placeName}\n'
            '地址：${site.displayAddress}\n'
            '資料版本：$datasetVersion\n'
            'App 版本：$appVersion\n',
      },
    );
  }

  Uri generalFeedback() {
    return Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': '台灣 ATM Finder 意見回饋',
        'body': '請在此輸入意見：\n\nApp 版本：$appVersion\n',
      },
    );
  }
}
