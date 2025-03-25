import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesDatasource {
  Future<List<Map<String, dynamic>>> getServerList();
  Future<bool> saveServerList(List<Map<String, dynamic>> servers);
  Future<Map<String, dynamic>?> getSettings();
  Future<bool> saveSettings(Map<String, dynamic> settings);
}

class PreferencesDatasourceImpl implements PreferencesDatasource {
  static const String _serverListKey = 'server_list';
  static const String _settingsKey = 'settings';

  @override
  Future<List<Map<String, dynamic>>> getServerList() async {
    final prefs = await SharedPreferences.getInstance();
    final serverListJson = prefs.getString(_serverListKey);

    if (serverListJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(serverListJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> saveServerList(List<Map<String, dynamic>> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final serverListJson = jsonEncode(servers);
    return await prefs.setString(_serverListKey, serverListJson);
  }

  @override
  Future<Map<String, dynamic>?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return null;
    }

    try {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings);
    return await prefs.setString(_settingsKey, settingsJson);
  }
}