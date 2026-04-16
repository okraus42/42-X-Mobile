import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/city.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final Function(City) onCitySelected;
  final VoidCallback onLocationPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onCitySelected,
    required this.onLocationPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  List<City> _suggestions = [];
  bool _isLoading = false;

  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  void _clearSearch() {
    widget.controller.clear();
    setState(() => _suggestions = []);
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];

        setState(() {
          _suggestions =
              results.map((e) => City.fromJson(e)).toList();
        });
      }
    } catch (_) {
      setState(() => _suggestions = []);
    }

    setState(() => _isLoading = false);
  }

  void _selectCity(City city) {
    widget.controller.text = city.name;

    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    setState(() => _suggestions = []);

    widget.onCitySelected(city);

    _clearSearch();
  }

  void _handleSubmit(String value) {
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    if (_suggestions.isNotEmpty) {
      final topCity = _suggestions.first;

      widget.controller.text = topCity.name;
      widget.onCitySelected(topCity);
    } else {
      widget.onSubmitted(value);
    }

    setState(() => _suggestions = []);
    _clearSearch();
  }

  void _handleGps() {
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    setState(() => _suggestions = []);

    _clearSearch();

    widget.onLocationPressed();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _suggestions = []);
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    _debounce =
                        Timer(const Duration(milliseconds: 400), () {
                      _fetchSuggestions(value);
                    });
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _handleSubmit,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _handleGps,
              ),
            ],
          ),

          if (_suggestions.isNotEmpty)
            Container(
              color: Colors.white,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final city = _suggestions[index];

                  return InkWell(
                    onTap: () => _selectCity(city),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${city.region}, ${city.country}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}