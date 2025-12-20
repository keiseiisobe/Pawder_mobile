import 'package:flutter/material.dart';

enum DogBehavior {
  drinking,
  playing,
  resting,
  shaking,
  sniffing,
  trotting,
  walking,
}

extension DogBehaviorExtension on DogBehavior {
  String get displayName {
    switch (this) {
      case DogBehavior.drinking:
        return '水を飲んでいます';
      case DogBehavior.playing:
        return '遊んでいます';
      case DogBehavior.resting:
        return '休んでいます';
      case DogBehavior.shaking:
        return '震えています';
      case DogBehavior.sniffing:
        return '匂いを嗅いでいます';
      case DogBehavior.trotting:
        return '小走りしています';
      case DogBehavior.walking:
        return '歩いています';
    }
  }

  IconData get icon {
    switch (this) {
      case DogBehavior.drinking:
        return Icons.local_drink;
      case DogBehavior.playing:
        return Icons.sports_tennis;
      case DogBehavior.resting:
        return Icons.hotel;
      case DogBehavior.shaking:
        return Icons.vibration;
      case DogBehavior.sniffing:
        return Icons.search;
      case DogBehavior.trotting:
        return Icons.directions_run;
      case DogBehavior.walking:
        return Icons.directions_walk;
    }
  }

  Color get color {
    switch (this) {
      case DogBehavior.drinking:
        return Colors.blue;
      case DogBehavior.playing:
        return Colors.orange;
      case DogBehavior.resting:
        return Colors.purple;
      case DogBehavior.shaking:
        return Colors.red;
      case DogBehavior.sniffing:
        return Colors.green;
      case DogBehavior.trotting:
        return Colors.amber;
      case DogBehavior.walking:
        return Colors.indigo;
    }
  }
}

class DogStatusModel {
  final DogBehavior behavior;
  final int? batteryLevel;
  final DateTime timestamp;

  DogStatusModel({
    required this.behavior,
    this.batteryLevel,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  DogStatusModel copyWith({
    DogBehavior? behavior,
    int? batteryLevel,
    DateTime? timestamp,
  }) {
    return DogStatusModel(
      behavior: behavior ?? this.behavior,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'DogStatusModel{behavior: $behavior, batteryLevel: $batteryLevel, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DogStatusModel &&
        other.behavior == behavior &&
        other.batteryLevel == batteryLevel;
  }

  @override
  int get hashCode {
    return behavior.hashCode ^ batteryLevel.hashCode;
  }
}

class DeviceConnectionModel {
  final String? deviceId;
  final String? deviceName;
  final bool isConnected;
  final String? connectionStatus;

  DeviceConnectionModel({
    this.deviceId,
    this.deviceName,
    required this.isConnected,
    this.connectionStatus,
  });

  DeviceConnectionModel copyWith({
    String? deviceId,
    String? deviceName,
    bool? isConnected,
    String? connectionStatus,
  }) {
    return DeviceConnectionModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      isConnected: isConnected ?? this.isConnected,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  String toString() {
    return 'DeviceConnectionModel{deviceId: $deviceId, deviceName: $deviceName, isConnected: $isConnected, connectionStatus: $connectionStatus}';
  }
}