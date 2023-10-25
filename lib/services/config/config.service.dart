/**
 * @created 25/10/2023 - 13:32
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  Future<void> loadConfig({String? envFileName}) async {
    await dotenv.load(fileName: envFileName ?? '.env.dev');
  }

  String get apiUrl => dotenv.env['API_BASE_URL'] ?? '';

  String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';
}
