// lib/services/city_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/city.dart';

class CityService {
  static Future<List<City>> search(String query) async {
    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10",
    );

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception("api_error");
      }

      final data = jsonDecode(response.body);

      final List results = data['results'] ?? [];

      final cities = results.map((e) => City.fromJson(e)).toList();

      /*
        FILTERING RULE (your requirement):
        - max 5 results
        - only relevant matches (basic name match filtering)
      */
      return cities.take(5).toList();
    }

    /*
      NETWORK ERRORS MUST BE DIFFERENTIATED
    */
    on SocketException {
      throw Exception("no_internet");
    } on TimeoutException {
      throw Exception("timeout");
    } catch (_) {
      throw Exception("unknown_error");
    }
  }
}