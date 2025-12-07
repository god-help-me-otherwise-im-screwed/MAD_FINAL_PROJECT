import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/api/api_service.dart';
import 'package:hawahawa/models/location_model.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';

class SearchLocationScreen extends ConsumerStatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  ConsumerState<SearchLocationScreen> createState() =>
      _SearchLocationScreenState();
}

class _SearchLocationScreenState extends ConsumerState<SearchLocationScreen> {
  final _searchController = TextEditingController();
  List<LocationResult> _suggestions = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await LocationAPI.searchLocations(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _selectLocation(LocationResult location) async {
    setState(() => _isSearching = true);
    try {
      ref.read(locationProvider.notifier).setLocation(location);
      await ref.read(weatherProvider.notifier).fetchWeather(location);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (c) => const WeatherDisplayScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: kDarkPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: kDarkText),
              decoration: InputDecoration(
                hintText: 'Enter city name...',
                hintStyle: TextStyle(color: kDarkText.withValues(alpha: 0.5)),
                filled: true,
                fillColor: kDarkPrimary.withValues(alpha: 0.7),
                prefixIcon: const Icon(Icons.location_on, color: kDarkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDarkAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kDarkAccent.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDarkAccent, width: 2),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kDarkAccent,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kDarkPrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDarkAccent.withValues(alpha: 0.3)),
                  ),
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final location = _suggestions[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: kDarkAccent,
                          size: 20,
                        ),
                        title: Text(
                          location.displayName,
                          style: const TextStyle(color: kDarkText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${location.lat.toStringAsFixed(2)}, ${location.lon.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: kDarkText.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => _selectLocation(location),
                        tileColor: Colors.transparent,
                        hoverColor: kDarkAccent.withValues(alpha: 0.1),
                      );
                    },
                  ),
                ),
              )
            else if (_searchController.text.isNotEmpty && !_isSearching)
              Expanded(
                child: Center(
                  child: Text(
                    'No results found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kDarkText.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 48,
                        color: kDarkText.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for a city',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kDarkText.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Popular Cities:',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: kDarkText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                                  'Lahore',
                                  'Karachi',
                                  'Islamabad',
                                  'London',
                                  'New York',
                                  'Tokyo',
                                ]
                                .map(
                                  (city) => GestureDetector(
                                    onTap: () {
                                      _searchController.text = city;
                                      _onSearchChanged(city);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kDarkAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: kDarkAccent.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        city,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: kDarkText),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
