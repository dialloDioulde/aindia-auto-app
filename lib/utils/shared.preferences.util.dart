/**
 * @created 16/10/2023 - 15:23
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  late SharedPreferences preferences;

  Future<String> getToken() async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString('token') ?? '';
  }

  void setLocalDataByKey(String key, String value) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('$key', value);
  }

  Future getLocalDataByKey(String key) async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? '';
  }
}
