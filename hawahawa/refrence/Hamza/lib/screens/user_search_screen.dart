import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/services/firebase_social_service.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final Map<String, bool> _requestSentMap = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      print('Searching for: $query');
      final socialService = ref.read(firebaseSocialServiceProvider);
      final results = await socialService.searchUsers(query.trim());
      print('Search results: ${results.length} users found');
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('SEARCH USERS'),
        backgroundColor: kDarkPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: kDarkText),
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: TextStyle(color: kDarkText.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: kDarkAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: kDarkText),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: kDarkSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDarkAccent, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.trim().isNotEmpty) {
                  _performSearch(value);
                } else {
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: kDarkAccent),
              ),
            )
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: kDarkText.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(color: kDarkText.withOpacity(0.5), fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: kDarkText.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Search for users',
                      style: TextStyle(color: kDarkText.withOpacity(0.5), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a username to find friends',
                      style: TextStyle(color: kDarkText.withOpacity(0.3), fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  final username = user['username'] ?? 'Unknown';
                  final displayName = user['displayName'] ?? 'Unknown';
                  final userId = user['userId'];

                  final requestSent = _requestSentMap[userId] ?? false;

                  return Card(
                    color: kDarkSecondary,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kDarkAccent,
                        child: Text(
                          username[0].toUpperCase(),
                          style: const TextStyle(color: kDarkText, fontSize: 20),
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          color: kDarkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '@$username',
                        style: const TextStyle(color: kDarkAccent, fontSize: 14),
                      ),
                      trailing: requestSent
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kDarkAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kDarkAccent),
                              ),
                              child: const Text(
                                'SENT',
                                style: TextStyle(color: kDarkAccent, fontSize: 12),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final socialService = ref.read(firebaseSocialServiceProvider);
                                  await socialService.sendFriendRequest(userId, username);
                                  setState(() {
                                    _requestSentMap[userId] = true;
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Friend request sent to @$username!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString().replaceAll('Exception: ', '')),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('ADD'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kDarkAccent,
                                foregroundColor: kDarkText,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
