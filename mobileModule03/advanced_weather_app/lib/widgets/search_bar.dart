// lib/widgets/search_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/city.dart';
import '../services/city_service.dart';

/// Defines errors that can happen during city search only.
/// This is separate from weather errors.
enum SearchErrorType {
  cityNotFound,
  noInternet,
  unknown,
}

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(City) onCitySelected;
  final VoidCallback onLocationPressed;

  /// Reports search-specific errors to parent layer.
  /// This prevents mixing search errors with weather errors.
  final void Function(SearchErrorType type) onSearchError;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onCitySelected,
    required this.onLocationPressed,
    required this.onSearchError,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  // Suggestions currently shown in dropdown
  List<City> _suggestions = [];

  // Loading state for UI feedback
  bool _isLoading = false;

  // Debounce timer for typing
  Timer? _debounce;

  // Request id prevents race conditions between async calls
  int _requestId = 0;

  // Locks search updates after selection/submit to prevent UI overwrite
  bool _lockSearch = false;

  /*
    Fetch suggestions from API safely.

    Important rules:
    - Only latest request can update UI
    - Network failures are NOT "city not found"
    - Empty results are valid "city not found"
  */
  Future<void> _search(String query) async {
    if (_lockSearch) return;

    if (query.isEmpty) {
      if (mounted) setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final int currentRequest = ++_requestId;

    try {
      final results = await CityService.search(query);

      if (!mounted || _lockSearch || currentRequest != _requestId) return;

      // CASE 1: valid response but no matches
      if (!mounted || _lockSearch || currentRequest != _requestId) return;

      if (results.isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });

        // Only signal if user is actively typing
        if (query.trim().isNotEmpty) {
          widget.onSearchError(SearchErrorType.cityNotFound);
        }

        return;
      }

      // CASE 2: valid results
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });

    } catch (_) {
      /*
        IMPORTANT RULE:
        This is NOT "city not found".
        This is ALWAYS network/system failure.
      */

      if (!mounted || _lockSearch || currentRequest != _requestId) return;

      setState(() {
        _suggestions = [];
        _isLoading = false;
      });

      if (currentRequest == _requestId) {
        widget.onSearchError(SearchErrorType.noInternet);
      }
    }
  }

  /*
    Debounced input handler.
    Prevents excessive API calls.
  */
  void _onChanged(String value) {
    _lockSearch = false;

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(value),
    );
  }

  /*
    Clears search UI state.
  */
  void _clearSearch() {
    widget.controller.clear();
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = []);
  }

  /*
    User selects a city from suggestions.
    This is always a valid city (from API results).
  */
  void _selectCity(City city) {
    _lockSearch = true;
    _requestId++;

    widget.controller.text = city.name;

    FocusScope.of(context).unfocus();

    setState(() => _suggestions = []);

    widget.onCitySelected(city);

    _clearSearch();
  }

  /*
    Enter key behavior.

    Rules:
    - If suggestions exist, use top match
    - Otherwise treat as invalid city input
  */
  void _handleSubmit(String value) {
    FocusScope.of(context).unfocus();

    _lockSearch = true;
    _debounce?.cancel();
    _requestId++;

    if (_suggestions.isNotEmpty) {
      final city = _suggestions.first;

      // Valid selection path
      widget.controller.text = city.name;
      widget.onCitySelected(city);

      setState(() => _suggestions = []);
      _clearSearch();
      return;
    }

    final input = widget.controller.text.trim();

    if (input.isEmpty || _isLoading) {
      // Do nothing: avoid false error during race / load
      _clearSearch();
      return;
    }

    setState(() => _suggestions = []);
    _clearSearch();

    widget.onSearchError(SearchErrorType.cityNotFound);
  }

  /*
    GPS button:
    - cancels search state
    - does not trigger search error logic
  */
  void _handleGps() {
    _debounce?.cancel();
    _requestId++;

    _clearSearch();

    widget.onLocationPressed();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      // Close suggestions when tapping outside
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _suggestions = []);
      },

      child: Column(
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
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: _onChanged,
                    onSubmitted: _handleSubmit,
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

          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Colors.white70,
              backgroundColor: Colors.transparent,
            ),

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
      ),
    );
  }
}