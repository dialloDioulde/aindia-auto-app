import 'package:shared_preferences/shared_preferences.dart';

class AuthUtil {
  late SharedPreferences preferences;

  Future<String> getToken() async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString('token') ?? '';
  }
}
