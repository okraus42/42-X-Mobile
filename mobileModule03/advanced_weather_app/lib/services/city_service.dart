// lib/services/city_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/city.dart';

class CityService {
  static Future<List<City>> search(String query) async {
    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final List results = data['results'] ?? [];

    return results.map((e) => City.fromJson(e)).toList();
  }
}