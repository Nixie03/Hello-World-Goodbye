import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class OnlineHealthResult {
  final String source;
  final String title;
  final String snippet;
  final String? url;

  OnlineHealthResult({
    required this.source,
    required this.title,
    required this.snippet,
    this.url,
  });
}

class OnlineHealthService {
  static final OnlineHealthService instance = OnlineHealthService._internal();
  OnlineHealthService._internal();

  Future<List<OnlineHealthResult>> search(String query) async {
    final results = <OnlineHealthResult>[];
    results.addAll(await _searchMedlinePlus(query));
    results.addAll(await _searchOpenFda(query));
    return results;
  }

  Future<List<OnlineHealthResult>> _searchMedlinePlus(String query) async {
    final uri = Uri.parse(
      'https://wsearch.nlm.nih.gov/ws/query?db=healthTopics&term=${Uri.encodeComponent(query)}&retmax=5&rettype=brief',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final document = XmlDocument.parse(response.body);
    final results = <OnlineHealthResult>[];

    for (final doc in document.findAllElements('document')) {
      String? title;
      String? snippet;
      String? url;

      for (final content in doc.findAllElements('content')) {
        final name = content.getAttribute('name') ?? '';
        if (name == 'title') {
          title = content.text.trim();
        } else if (name == 'snippet') {
          snippet = content.text.trim();
        } else if (name == 'url') {
          url = content.text.trim();
        }
      }

      if (title != null && snippet != null) {
        results.add(
          OnlineHealthResult(
            source: 'MedlinePlus',
            title: title,
            snippet: snippet,
            url: url,
          ),
        );
      }
    }

    return results;
  }

  Future<List<OnlineHealthResult>> _searchOpenFda(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://api.fda.gov/drug/label.json?search=openfda.generic_name:$encoded+openfda.brand_name:$encoded&limit=5',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];

    return results.map((item) {
      final map = item as Map<String, dynamic>;
      final openfda = map['openfda'] as Map<String, dynamic>? ?? {};
      final brand = (openfda['brand_name'] as List?)
          ?.cast<String>()
          .firstOrNull;
      final generic = (openfda['generic_name'] as List?)
          ?.cast<String>()
          .firstOrNull;
      final title = brand ?? generic ?? 'Medication';

      final descriptionList = (map['description'] as List?)?.cast<String>();
      final usageList = (map['indications_and_usage'] as List?)?.cast<String>();
      final snippet = (usageList?.isNotEmpty == true)
          ? usageList!.first
          : (descriptionList?.isNotEmpty == true)
          ? descriptionList!.first
          : 'No description available.';

      return OnlineHealthResult(
        source: 'OpenFDA',
        title: title,
        snippet: snippet,
        url: null,
      );
    }).toList();
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
