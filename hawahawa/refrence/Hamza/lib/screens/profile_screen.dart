import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/auth_provider.dart';
import 'package:hawahawa/services/firebase_social_service.dart';
import 'package:hawahawa/services/firebase_presets_service.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socialService = ref.watch(firebaseSocialServiceProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('PROFILE'),
        backgroundColor: kDarkPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kDarkAccent),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kDarkAccent,
          labelColor: kDarkText,
          unselectedLabelColor: kDarkText.withOpacity(0.5),
          tabs: const [
            Tab(text: 'PROFILE'),
            Tab(text: 'REQUESTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(socialService),
          _buildRequestsTab(socialService),
        ],
      ),
    );
  }

  Widget _buildProfileTab(FirebaseSocialService socialService) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: socialService.getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kDarkAccent));
        }

        final userData = snapshot.data;
        if (userData == null) {
          return const Center(
            child: Text('Error loading profile', style: TextStyle(color: kDarkText)),
          );
        }

        final username = userData['username'] ?? 'Unknown';
        final displayName = userData['displayName'] ?? 'Unknown';
        final email = userData['email'] ?? 'Unknown';
        final friendsCount = userData['friendsCount'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ScenePanel(
                minWidth: double.infinity,
                minHeight: 150,
                showBorder: true,
                borderWidth: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [kDarkAccent, kDarkAccent.withOpacity(0.5)],
                          ),
                        ),
                        child: const Icon(Icons.person, size: 50, color: kDarkText),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: kDarkText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: kDarkAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(
                          color: kDarkText.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ScenePanel(
                      minWidth: 100,
                      minHeight: 100,
                      showBorder: true,
                      borderWidth: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$friendsCount',
                              style: const TextStyle(
                                color: kDarkAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'FRIENDS',
                              style: TextStyle(
                                color: kDarkText,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ref.watch(firebasePresetsServiceProvider).getUserPresets(),
                      builder: (context, presetsSnapshot) {
                        final presetsCount = presetsSnapshot.data?.length ?? 0;
                        return ScenePanel(
                          minWidth: 100,
                          minHeight: 100,
                          showBorder: true,
                          borderWidth: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$presetsCount',
                                  style: const TextStyle(
                                    color: kDarkAccent,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'PRESETS',
                                  style: TextStyle(
                                    color: kDarkText,
                                    fontSize: 12,
                                    letterSpacing: 1,
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
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'FRIENDS',
                  style: TextStyle(
                    color: kDarkText.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: socialService.getFriends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: kDarkAccent);
                  }

                  final friends = snapshot.data ?? [];

                  if (friends.isEmpty) {
                    return ScenePanel(
                      minWidth: double.infinity,
                      minHeight: 100,
                      showBorder: true,
                      borderWidth: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No friends yet. Search for users to add!',
                            style: TextStyle(color: kDarkText.withOpacity(0.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final username = friend['username'] ?? 'Unknown';
                      final userId = friend['userId'];

                      return Card(
                        color: kDarkSecondary,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kDarkAccent,
                            child: Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(color: kDarkText),
                            ),
                          ),
                          title: Text(
                            '@$username',
                            style: const TextStyle(color: kDarkText),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_remove, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: kDarkSecondary,
                                  title: const Text('Remove Friend?', style: TextStyle(color: kDarkText)),
                                  content: Text(
                                    'Remove @$username from friends?',
                                    style: const TextStyle(color: kDarkText),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('CANCEL', style: TextStyle(color: kDarkText)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await socialService.removeFriend(userId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Friend removed')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab(FirebaseSocialService socialService) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: socialService.getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kDarkAccent));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: kDarkText.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No pending requests',
                  style: TextStyle(color: kDarkText.withOpacity(0.5), fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final fromUsername = request['fromUsername'] ?? 'Unknown';
            final fromUserId = request['fromUserId'];
            final requestId = request['requestId'];

            return Card(
              color: kDarkSecondary,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kDarkAccent,
                  child: Text(
                    fromUsername[0].toUpperCase(),
                    style: const TextStyle(color: kDarkText),
                  ),
                ),
                title: Text(
                  '@$fromUsername',
                  style: const TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'wants to be friends',
                  style: TextStyle(color: kDarkText),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        try {
                          await socialService.acceptFriendRequest(requestId, fromUserId, fromUsername);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Now friends with @$fromUsername!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await socialService.rejectFriendRequest(requestId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request rejected')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
