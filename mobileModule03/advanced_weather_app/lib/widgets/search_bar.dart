// widgets/search_bar.dart

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

  // 🚨 prevents race conditions between GPS + search
  bool _isGpsActive = false;

  Future<void> _fetchSuggestions(String query) async {
    if (_isGpsActive) return;

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

      // ignore stale responses during GPS mode
      if (_isGpsActive) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];

        setState(() {
          _suggestions =
              results.map((e) => City.fromJson(e)).take(5).toList();
        });
      }
    } catch (_) {
      if (!_isGpsActive) {
        setState(() => _suggestions = []);
      }
    }

    if (!_isGpsActive) {
      setState(() => _isLoading = false);
    }
  }

  void _selectCity(City city) {
    widget.controller.text = city.name;

    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    setState(() => _suggestions = []);

    widget.onCitySelected(city);
  }

  void _handleSubmit(String value) {
    if (_isGpsActive) return;

    final hasSuggestions = _suggestions.isNotEmpty;
    final topCity = hasSuggestions ? _suggestions.first : null;

    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    setState(() => _suggestions = []);

    if (topCity != null) {
      widget.controller.text = topCity.name;
      widget.onCitySelected(topCity);
    } else {
      widget.onSubmitted(value);
    }
  }

  void _handleGps() {
    _isGpsActive = true;

    // cancel pending debounce search immediately
    _debounce?.cancel();

    // clear input + UI instantly
    widget.controller.clear();

    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    setState(() {
      _suggestions = [];
      _isLoading = false;
    });

    // trigger parent GPS fetch
    widget.onLocationPressed();

    // release lock after short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      _isGpsActive = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            "Search for a city",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,

                onSubmitted: _handleSubmit,

                onChanged: (value) {
                  if (_isGpsActive) return;

                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 350),
                    () => _fetchSuggestions(value),
                  );
                },

                textInputAction: TextInputAction.search,

                decoration: InputDecoration(
                  hintText: 'Search city...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: IconButton(
                tooltip: "Use my location",
                icon: const Icon(Icons.gps_fixed),
                color: Colors.blue,
                onPressed: _handleGps,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),

        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final city = _suggestions[index];

                return InkWell(
                  onTap: () => _selectCity(city),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          size: 18,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: city.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      " • ${city.region}, ${city.country}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}