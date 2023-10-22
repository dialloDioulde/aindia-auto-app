/**
 * @created 22/10/2023 - 10:59
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/models/order/order.model.dart';
import 'package:aindia_auto_app/utils/shared.preferences.util.dart';
import 'package:http/http.dart' as http;

import '../../utils/headers.header.dart.dart';
import '../../utils/router-api.constants.dart';

class OrderService {
  Future<http.Response> createOrder(OrderModel orderModel) async {
    final token = await SharedPreferencesUtil().getToken();
    return await http.post(
        Uri.parse(RouterApiConstants.apiURL + RouterApiConstants.createOrder),
        headers: HeadersHeaderDart.headersWithToken(token),
        body: jsonEncode(orderModel));
  }

}
