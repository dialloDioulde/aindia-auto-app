/**
 * @created 22/10/2023 - 10:59
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:http/http.dart' as http;

import '../../utils/headers.header.dart';
import '../../utils/router-api.constants.dart';
import '../config/config.service.dart';

class OrderService {
  String apiUrl = ConfigService().apiUrl;

  Future<http.Response> createOrder(orderModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(apiUrl + RouterApiConstants.createOrder),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderModel));
  }

  Future<http.Response> cancelOrder(orderModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.put(
        Uri.parse(apiUrl + RouterApiConstants.cancelOrder + orderModel["_id"]),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderModel));
  }

  Future<http.Response> sendOrderToDriver(data) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(apiUrl + RouterApiConstants.sendOrderToDriver),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(data));
  }

}
