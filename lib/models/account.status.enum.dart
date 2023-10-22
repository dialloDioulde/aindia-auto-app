/**
 * @created 20/10/2023 - 23:13
 * @project aindia_auto_app
 * @author mamadoudiallo
 */


enum UserStatusEnum {
  ACTIVATED,
  NOT_ACTIVATED,
  BANNED,
  SUSPENDED,
}

class UserStatus {
  String getUserRole(int? userStatusValue) {
    var userRole = "";
    switch (userStatusValue) {
      case 1:
        userRole = "Actif";
        break;
      case 2:
        userRole = "Inactif";
        break;
      case 3:
        userRole = "Banni";
        break;
      case 4:
        userRole = "Suspendu";
        break;
    }
    return userRole;
  }
}