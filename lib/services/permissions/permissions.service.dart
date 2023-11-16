/**
 * @created 15/11/2023 - 11:30
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:permission_handler/permission_handler.dart';

import '../../models/account-type.enum.dart';
import '../../utils/permissions/permission.handler.dart';

class PermissionsService {
  AccountType accountType = AccountType();
  PermissionHandler permissionHandler = PermissionHandler();

  Future<bool> checkPermissionsByAccountType(accountModel) async {
    if (accountModel.id != null &&
        accountModel.id != '' &&
        accountModel.getAccountType! ==
            accountType.accountTypeValue(AccountTypeEnum.DRIVER)) {
      final permissions = [
        Permission.location,
        Permission.notification,
        Permission.camera,
      ];
      return await permissionHandler.checkPermissions(permissions);
    } else {
      final permissions = [
        Permission.location,
        Permission.notification,
      ];
      return await permissionHandler.checkPermissions(permissions);
    }
  }
}
