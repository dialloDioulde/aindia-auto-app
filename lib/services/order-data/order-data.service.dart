/**
 * @created 27/12/2023 - 02:18
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:http/http.dart' as http;

import '../../utils/headers.header.dart';
import '../../utils/router-api.constants.dart';
import '../config/config.service.dart';

class OrderDataService {
  String apiUrl = ConfigService().apiUrl;

  Future<http.Response> getOrderData(orderModelId) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.get(
      Uri.parse(apiUrl + RouterApiConstants.orderData + orderModelId),
      headers: HeadersHeaderDart.headersWithToken(token),);
  }
}
