import 'package:flutter/material.dart';

class CustomPreset {
  final double cloudDensity;
  final double rainIntensity;
  final double windSpeedOverride;
  final Color skyGradientTop;
  final Color skyGradientBottom;
  final double particleCount;
  final double animationSpeed;

  const CustomPreset({
    this.cloudDensity = 0.5,
    this.rainIntensity = 0.0,
    this.windSpeedOverride = 10.0,
    this.skyGradientTop = const Color(0xFF1A0B2E),
    this.skyGradientBottom = const Color(0xFF431E4E),
    this.particleCount = 50.0,
    this.animationSpeed = 1.0,
  });

  CustomPreset copyWith({
    double? cloudDensity,
    double? rainIntensity,
    double? windSpeedOverride,
    Color? skyGradientTop,
    Color? skyGradientBottom,
    double? particleCount,
    double? animationSpeed,
  }) {
    return CustomPreset(
      cloudDensity: cloudDensity ?? this.cloudDensity,
      rainIntensity: rainIntensity ?? this.rainIntensity,
      windSpeedOverride: windSpeedOverride ?? this.windSpeedOverride,
      skyGradientTop: skyGradientTop ?? this.skyGradientTop,
      skyGradientBottom: skyGradientBottom ?? this.skyGradientBottom,
      particleCount: particleCount ?? this.particleCount,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cloudDensity': cloudDensity,
      'rainIntensity': rainIntensity,
      'windSpeedOverride': windSpeedOverride,
      'skyGradientTop': skyGradientTop.value,
      'skyGradientBottom': skyGradientBottom.value,
      'particleCount': particleCount,
      'animationSpeed': animationSpeed,
    };
  }

  factory CustomPreset.fromMap(Map<String, dynamic> map) {
    return CustomPreset(
      cloudDensity: map['cloudDensity'] ?? 0.5,
      rainIntensity: map['rainIntensity'] ?? 0.0,
      windSpeedOverride: map['windSpeedOverride'] ?? 10.0,
      skyGradientTop: Color(map['skyGradientTop'] ?? 0xFF1A0B2E),
      skyGradientBottom: Color(map['skyGradientBottom'] ?? 0xFF431E4E),
      particleCount: map['particleCount'] ?? 50.0,
      animationSpeed: map['animationSpeed'] ?? 1.0,
    );
  }
}