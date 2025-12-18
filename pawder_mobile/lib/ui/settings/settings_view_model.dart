import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String ownerName = '山田 太郎';
  String email = 'taro.yamada@example.com';

  bool isBluetoothEnabled = true;
  bool isAutoSyncEnabled = true;

  void toggleBluetooth(bool value) {
    isBluetoothEnabled = value;
    notifyListeners();
  }

  void toggleAutoSync(bool value) {
    isAutoSyncEnabled = value;
    notifyListeners();
  }
}


