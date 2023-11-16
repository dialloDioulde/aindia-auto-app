/**
 * @created 15/11/2023 - 22:04
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/services/config/config.service.dart';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:http/http.dart' as http;

import '../../../utils/headers.header.dart';
import '../../../utils/router-api.constants.dart';


class TokenDeviceService {
  String apiUrl = ConfigService().apiUrl;

  Future<http.Response> createOrUpdateDeviceToken(tokenDeviceModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(apiUrl + RouterApiConstants.createOrUpdateDeviceToken),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(tokenDeviceModel));
  }

}