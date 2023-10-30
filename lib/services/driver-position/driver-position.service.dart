/**
 * @created 29/10/2023 - 16:35
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:http/http.dart' as http;

import '../../models/driver-position/driver-position.model.dart';
import '../../utils/headers.header.dart';
import '../../utils/router-api.constants.dart';
import '../config/config.service.dart';

class DriverPositionService {
  String apiUrl = ConfigService().apiUrl;

  Future<http.Response> createOrUpdateDriverPosition(DriverPositionModel driverPositionModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(apiUrl + RouterApiConstants.createOrUpdateDriverPosition),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(driverPositionModel));
  }

}