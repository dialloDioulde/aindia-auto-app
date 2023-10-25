/**
 * @created 20/10/2023 - 23:13
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

enum AccountStatusEnum {
  ACTIVATED,
  NOT_ACTIVATED,
  BANNED,
  SUSPENDED,
}

class AccountStatus {
  String getAccountStatus(int accountStatusValue) {
    var accountStatus = "";
    switch (accountStatusValue) {
      case 1:
        accountStatus = "Actif";
        break;
      case 2:
        accountStatus = "Inactif";
        break;
      case 3:
        accountStatus = "Banni";
        break;
      case 4:
        accountStatus = "Suspendu";
        break;
    }
    return accountStatus;
  }
}
