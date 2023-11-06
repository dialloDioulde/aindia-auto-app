/**
 * @created 05/11/2023 - 22:31
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.notification,
      Permission.camera,
      // Add more permissions as needed
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    if (statuses[Permission.location] == PermissionStatus.granted &&
        statuses[Permission.notification] == PermissionStatus.granted &&
        statuses[Permission.camera] == PermissionStatus.granted) {
      // All permissions are granted, you can proceed
      return true;
    } else {
      // Handle the case where not all permissions are granted
      return false;
    }
  }
}
