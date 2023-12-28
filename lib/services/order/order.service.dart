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
    return await http.post(Uri.parse(apiUrl + RouterApiConstants.createOrder),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderModel));
  }

  Future<http.Response> getOrder(orderModelId) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.get(
      Uri.parse(apiUrl + RouterApiConstants.order + orderModelId),
      headers: HeadersHeaderDart.headersWithToken(token),
    );
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

  Future<http.Response> acceptOrder(orderDataModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.put(
        Uri.parse(apiUrl + RouterApiConstants.acceptOrder + orderDataModel["orderDataId"]),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderDataModel));
  }

  Future<http.Response> rejectOrder(orderDataModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.patch(
        Uri.parse(apiUrl + RouterApiConstants.rejectOrder + orderDataModel["orderDataId"]),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderDataModel));
  }
}
