// lib/widgets/search_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/city.dart';
import '../services/city_service.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(City) onCitySelected;
  final VoidCallback onLocationPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onCitySelected,
    required this.onLocationPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  List<City> _suggestions = [];
  bool _isLoading = false;

  Timer? _debounce;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await CityService.search(query);

      if (!mounted) return;

      setState(() => _suggestions = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = []);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(value),
    );
  }

  void _selectCity(City city) {
    widget.controller.text = city.name;
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = []);
    widget.onCitySelected(city);
  }

  void _handleGps() {
    _debounce?.cancel();
    widget.controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = [];
      _isLoading = false;
    });
    widget.onLocationPressed();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            "Search city",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),

        Row(
          children: [
            // 🟣 GLASS SEARCH FIELD
            Expanded(
              child: Container(
                height: 38, // 🔥 thinner
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18), // glass effect
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  onChanged: _onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: "Search city...",
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.white70,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 🟣 GLASS GPS BUTTON
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                tooltip: "Use my location",
                icon: const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                onPressed: _handleGps,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 🔄 loading
        if (_isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: Colors.white70,
            backgroundColor: Colors.transparent,
          ),

        // 📍 suggestions
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final city = _suggestions[index];

                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(city.name),
                  subtitle: Text("${city.region}, ${city.country}"),
                  onTap: () => _selectCity(city),
                );
              },
            ),
          ),
      ],
    );
  }
}