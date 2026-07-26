String normalizeSearchText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('臺', '台')
      .replaceAll(RegExp(r'[\s\u3000\-－]'), '');
}

String extractDistrict(String displayAddress, {String county = ''}) {
  var remainder = displayAddress.replaceAll(RegExp(r'[\s\u3000]'), '');
  if (county.isNotEmpty && remainder.startsWith(county)) {
    remainder = remainder.substring(county.length);
  }
  final matches = RegExp(
    r'([^縣市區鄉鎮]{1,6}(?:區|鄉|鎮|市))',
  ).allMatches(remainder).map((match) => match.group(1)!).toList();
  if (matches.length >= 2 && matches.first.endsWith('市')) {
    return matches[1];
  }
  return matches.isEmpty ? '' : matches.first;
}
