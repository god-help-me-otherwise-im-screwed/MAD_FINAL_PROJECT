import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseSocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    final queryLower = query.toLowerCase().trim();
    
    try {
      // Try exact match first
      final exactMatch = await _firestore
          .collection('users')
          .where('username', isEqualTo: queryLower)
          .get();
      
      if (exactMatch.docs.isNotEmpty) {
        return exactMatch.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) {
              final data = doc.data();
              data['userId'] = doc.id;
              return data;
            })
            .toList();
      }
      
      // Try prefix match
      final results = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: queryLower)
          .where('username', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      return results.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
            final data = doc.data();
            data['userId'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(String toUserId, String toUsername) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not logged in');

      if (currentUser.uid == toUserId) {
        throw Exception('Cannot add yourself as friend');
      }

      // Get current user data
      final userData = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userData.exists) throw Exception('User data not found');
      final fromUsername = userData.data()?['username'] ?? 'Unknown';

      // Check if request already exists
      final existing = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Friend request already sent');
      }

      // Check if already friends
      final friendDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(toUserId)
          .get();

      if (friendDoc.exists) {
        throw Exception('Already friends');
      }

      // Create friend request
      await _firestore.collection('friendRequests').add({
        'fromUserId': currentUser.uid,
        'toUserId': toUserId,
        'fromUsername': fromUsername,
        'toUsername': toUsername,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Get pending friend requests (received)
  Stream<List<Map<String, dynamic>>> getPendingRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['requestId'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requestId, String friendUserId, String friendUsername) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not logged in');

      // Get current user data first
      final currentUserData = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!currentUserData.exists) throw Exception('User data not found');
      final currentUsername = currentUserData.data()?['username'] ?? 'Unknown';

      final batch = _firestore.batch();

      // Update request status
      batch.update(
        _firestore.collection('friendRequests').doc(requestId),
        {'status': 'accepted'},
      );

      // Add to current user's friends
      batch.set(
        _firestore.collection('users').doc(currentUser.uid).collection('friends').doc(friendUserId),
        {
          'username': friendUsername,
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      // Add current user to friend's friends
      batch.set(
        _firestore.collection('users').doc(friendUserId).collection('friends').doc(currentUser.uid),
        {
          'username': currentUsername,
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update friends count for both users
      batch.update(
        _firestore.collection('users').doc(currentUser.uid),
        {'friendsCount': FieldValue.increment(1)},
      );
      batch.update(
        _firestore.collection('users').doc(friendUserId),
        {'friendsCount': FieldValue.increment(1)},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept: ${e.toString()}');
    }
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to reject: ${e.toString()}');
    }
  }

  // Get friends list
  Stream<List<Map<String, dynamic>>> getFriends() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    data?['userId'] = doc.id;
    return data;
  }

  // Remove friend
  Future<void> removeFriend(String friendUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    final batch = _firestore.batch();

    // Remove from current user's friends
    batch.delete(
      _firestore.collection('users').doc(currentUser.uid).collection('friends').doc(friendUserId),
    );

    // Remove current user from friend's friends
    batch.delete(
      _firestore.collection('users').doc(friendUserId).collection('friends').doc(currentUser.uid),
    );

    // Update friends count for both users
    batch.update(
      _firestore.collection('users').doc(currentUser.uid),
      {'friendsCount': FieldValue.increment(-1)},
    );
    batch.update(
      _firestore.collection('users').doc(friendUserId),
      {'friendsCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  // Get count of pending friend requests
  Stream<int> getPendingRequestsCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

// Provider for the service
final firebaseSocialServiceProvider = Provider<FirebaseSocialService>((ref) {
  return FirebaseSocialService();
});
