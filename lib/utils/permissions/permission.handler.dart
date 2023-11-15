/**
 * @created 05/11/2023 - 22:31
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<bool> requestPermissions(List<Permission> permissionsToRequest) async {
    Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();
    bool isGranted = true;
    statuses.forEach((permission, status) {
      if (status.isGranted) {
        print('${permission.toString()} is granted');
      } else {
        print('${permission.toString()} is denied');
        isGranted = false;
      }
    });
    return isGranted;
  }
}
