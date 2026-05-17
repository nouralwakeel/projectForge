import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends GetxService {
  static const String _ipKey = 'api_ip';
  static const String _portKey = 'api_port';

  final RxString apiIp = ''.obs;
  final RxString apiPort = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    apiIp.value = prefs.getString(_ipKey) ?? _defaultIp();
    apiPort.value = prefs.getString(_portKey) ?? '8000';
  }

  String _defaultIp() {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.204.231.62';
    } catch (_) {}
    return 'localhost';
  }

  String getBaseUrl() {
    final ip = apiIp.value.isEmpty ? _defaultIp() : apiIp.value;
    final port = apiPort.value.isEmpty ? '8000' : apiPort.value;
    return 'http://$ip:$port/api/v1';
  }

  Future<void> saveSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await prefs.setString(_portKey, port);
    apiIp.value = ip;
    apiPort.value = port;
  }
}
