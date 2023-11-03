/**
 * @created 03/11/2023 - 00:15
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/identity/identity.model.dart';
import '../../utils/headers.header.dart';
import '../../utils/router-api.constants.dart';
import '../../utils/shared-preferences.util.dart';
import '../config/config.service.dart';

class IdentityService {
  String apiUrl = ConfigService().apiUrl;

  Future<http.Response> createIdentity(IdentityModel identityModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(apiUrl + RouterApiConstants.createIdentity),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(identityModel));
  }

  Future<http.Response> updateIdentity(IdentityModel identityModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.put(
        Uri.parse(
            apiUrl + RouterApiConstants.updateIdentity + identityModel.id),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(identityModel));
  }
}
