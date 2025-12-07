import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/location_provider.dart';
import 'package:hawahawa/providers/weather_provider.dart';
import 'package:hawahawa/screens/weather_display_screen.dart';

class SearchLocationScreen extends ConsumerStatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  ConsumerState<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends ConsumerState<SearchLocationScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    await ref.read(locationProvider.notifier).searchLocation(_searchController.text);
    setState(() => _isSearching = false);
    
    final location = ref.read(locationProvider);
    if (location != null && mounted) {
      await ref.read(weatherProvider.notifier).fetchWeather(location.coords);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (c) => const WeatherDisplayScreen()),
        );
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
              style: const TextStyle(color: kDarkText),
              decoration: InputDecoration(
                hintText: 'Enter city name...',
                hintStyle: TextStyle(color: kDarkText.withOpacity(0.5)),
                filled: true,
                fillColor: kDarkPrimary.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kDarkAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: kDarkAccent.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kDarkAccent, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search, color: kDarkAccent),
                  onPressed: _isSearching ? null : _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 24),
            Text(
              'Try: Lahore, Karachi, Islamabad, New York, London',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kDarkText.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}