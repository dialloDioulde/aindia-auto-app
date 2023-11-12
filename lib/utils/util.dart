/**
 * @created 11/11/2023 - 18:40
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Util {
  static Future fetchUrl(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
