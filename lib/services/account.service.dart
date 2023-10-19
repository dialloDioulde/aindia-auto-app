/**
 * @created 18/10/2023 - 21:18
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/headers.header.dart.dart';
import '../utils/router-api.constants.dart';

class AccountService {
  Future<http.Response> loginAccount(userModel) async {
    return await http.post(
        Uri.parse(RouterApiConstants.apiURL + RouterApiConstants.loginAccount),
        headers: HeadersHeaderDart.headers(),
        body: jsonEncode(userModel));
  }

  Future<http.Response> registerAccount(userModel) async {
    return await http.post(
        Uri.parse(
            RouterApiConstants.apiURL + RouterApiConstants.registerAccount),
        headers: HeadersHeaderDart.headers(),
        body: jsonEncode(userModel));
  }
}
