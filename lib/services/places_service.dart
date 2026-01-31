import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaceHospital {
  final String name;
  final String address;
  final double? rating;
  final bool? openNow;

  PlaceHospital({
    required this.name,
    required this.address,
    this.rating,
    this.openNow,
  });
}

class PlacesService {
  static const String apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  Future<List<PlaceHospital>> searchHospitals({required String query}) async {
    if (apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      return [];
    }

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json'
      '?query=${Uri.encodeComponent(query)}'
      '&type=hospital'
      '&key=$apiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results =
        (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return results.map((item) {
      final geometry = item['geometry'] as Map<String, dynamic>?;
      final opening = item['opening_hours'] as Map<String, dynamic>?;
      return PlaceHospital(
        name: item['name'] as String? ?? 'Unknown',
        address: item['formatted_address'] as String? ?? 'Unknown address',
        rating: (item['rating'] as num?)?.toDouble(),
        openNow: opening?['open_now'] as bool?,
      );
    }).toList();
  }
}
