/**
 * @created 05/11/2023 - 22:31
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<bool> checkPermissions(List<Permission> permissionsToRequest) async {
    List<bool> mappedList = await Future.wait(permissionsToRequest.map(
      (permission) async => await permission.status.isGranted,
    ));
    List<bool> filteredList =
        mappedList.where((element) => element == false).toList();
    return filteredList.length <= 0;
  }

  Future<bool> requestPermissions(List<Permission> permissionsToRequest) async {
    Map<Permission, PermissionStatus> statuses =
        await permissionsToRequest.request();
    bool isGranted = true;
    for (var entry in statuses.entries) {
      PermissionStatus status = entry.value;
      if (!status.isGranted) {
        isGranted = false;
      }
    }
    return isGranted;
  }
}
