import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_restaurant/core/utile/web_branding.dart';
import '../services/config_service.dart';

class ConfigProvider with ChangeNotifier {
  final ConfigService configService;

  ConfigProvider({required this.configService});

  // Config properties
  String? appName;
  String appLogo = '';
  Color? primaryColor;
  Color? secondaryColor;
  String? welcomeMessage;
  bool enableOrders = true;
   String username = 'admin';  // Default
  String password = '123456'; // Default

  static const _storageKey = 'app_config';

  

  /// -----------------------------
  /// INITIAL LOAD (App start)
  /// -----------------------------
  Future<void> loadConfig() async {
    // await _loadFromLocal();
    await refreshFromServer();
  }

  /// -----------------------------
  /// FORCE REFRESH FROM BACKEND
  /// (Call this when page opens)
  /// -----------------------------
  Future<void> refreshFromServer() async {
    try {
      final backendConfig = await configService.fetchConfig();

      _applyConfig(backendConfig);
      await _saveToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Config refresh failed: $e");
    }
  }

  /// -----------------------------
  /// UPDATE FROM APP (Settings)
  /// -----------------------------
  Future<void> updateConfig(Map<String, dynamic> updates) async {
    try {
      final updatedBackendConfig =
          await configService.updateConfig(updates);

      _applyConfig(updatedBackendConfig);
      await _saveToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Config update failed: $e");
    }
  }

 
void _applyConfig(Map<String, dynamic> data) {
  appName = data['appName'] ?? appName;
  appLogo = data['appLogo'] ?? appLogo;
  primaryColor = _hexToColor(data['primaryColor']) ?? primaryColor;
  secondaryColor = _hexToColor(data['secondaryColor']) ?? secondaryColor;
  welcomeMessage = data['welcomeMessage'] ?? welcomeMessage;
  enableOrders = data['enableOrders'] ?? enableOrders;
   username = data['username'] ?? username;
    password = data['password'] ?? password;

  // 🌐 Update web-specific branding
  if (kIsWeb) {
    if (appName != null) WebBranding.setTitle(appName!);
    if (appLogo.isNotEmpty) WebBranding.setFavicon(appLogo);
  }
}

  /// -----------------------------
  /// LOCAL STORAGE
  /// -----------------------------
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      final data = json.decode(raw);
      _applyConfig(data);
    }
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode({
        'appName': appName,
        'appLogo': appLogo,
        'primaryColor': _colorToHex(primaryColor),
        'secondaryColor': _colorToHex(secondaryColor),
        'welcomeMessage': welcomeMessage,
        'enableOrders': enableOrders,
       
      }),
    );
  }

  /// -----------------------------
  /// HELPERS
  /// -----------------------------
  Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
