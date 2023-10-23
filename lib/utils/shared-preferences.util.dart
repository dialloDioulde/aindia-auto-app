/**
 * @created 16/10/2023 - 15:23
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

  Future<AccountModel> getAccountDataFromToken() async {
    String token = await this.getToken();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);

    return AccountModel(
      jwtDecodedToken["_id"],
      accountId: jwtDecodedToken['accountId'],
      accountType: jwtDecodedToken['accountType'],
      phoneNumber: jwtDecodedToken['phoneNumber'],
      status: jwtDecodedToken['status'],
    );
  }
}
