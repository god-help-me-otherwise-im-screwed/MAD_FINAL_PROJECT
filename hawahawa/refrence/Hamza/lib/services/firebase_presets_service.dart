import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hawahawa/models/customizer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebasePresetsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save preset to Firestore
  Future<void> savePreset(CustomPreset preset, String presetName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final presetData = {
      'userId': user.uid,
      'presetName': presetName,
      'cloudDensity': preset.cloudDensity,
      'rainIntensity': preset.rainIntensity,
      'windSpeedOverride': preset.windSpeedOverride,
      'skyGradientTop': preset.skyGradientTop.value,
      'skyGradientBottom': preset.skyGradientBottom.value,
      'particleCount': preset.particleCount,
      'animationSpeed': preset.animationSpeed,
      'createdAt': FieldValue.serverTimestamp(),
      'isPublic': false, // Default to private
    };

    await _firestore.collection('presets').add(presetData);
  }

  // Get user's presets
  Stream<List<Map<String, dynamic>>> getUserPresets() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('presets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      // Sort manually to avoid requiring a Firestore index
      final presets = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
      
      // Sort by createdAt in descending order (newest first)
      presets.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // Descending order
      });
      
      return presets;
    });
  }

  // Get public presets (all users)
  Stream<List<Map<String, dynamic>>> getPublicPresets() {
    return _firestore
        .collection('presets')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to 50 most recent
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Delete preset
  Future<void> deletePreset(String presetId) async {
    await _firestore.collection('presets').doc(presetId).delete();
  }

  // Toggle public/private
  Future<void> togglePublic(String presetId, bool isPublic) async {
    await _firestore.collection('presets').doc(presetId).update({
      'isPublic': isPublic,
    });
  }

  // Convert Firestore data to CustomPreset
  CustomPreset mapToPreset(Map<String, dynamic> data) {
    return CustomPreset(
      cloudDensity: (data['cloudDensity'] ?? 0.5).toDouble(),
      rainIntensity: (data['rainIntensity'] ?? 0.0).toDouble(),
      windSpeedOverride: (data['windSpeedOverride'] ?? 10.0).toDouble(),
      skyGradientTop: Color(data['skyGradientTop'] ?? 0xFF1A0B2E),
      skyGradientBottom: Color(data['skyGradientBottom'] ?? 0xFF431E4E),
      particleCount: (data['particleCount'] ?? 50.0).toDouble(),
      animationSpeed: (data['animationSpeed'] ?? 1.0).toDouble(),
    );
  }
}

// Provider for the service
final firebasePresetsServiceProvider = Provider<FirebasePresetsService>((ref) {
  return FirebasePresetsService();
});
