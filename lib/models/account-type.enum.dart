/**
 * @created 25/10/2023 - 14:57
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

enum AccountTypeEnum { PASSENGER, DRIVER }

class AccountType {
  int accountTypeValue(AccountTypeEnum value) {
    int accountType = 1;
    switch (value) {
      case AccountTypeEnum.PASSENGER:
        accountType = 1;
        break;
      case AccountTypeEnum.DRIVER:
        accountType = 2;
        break;
    }
    return accountType;
  }

  String getAccountTypeValue(accountType) {
    String accountTypeValue;
    switch (accountType) {
      case 1:
        accountTypeValue = "Passager";
        break;
      case 2:
        accountTypeValue = "Chauffeur";
        break;
      default:
        accountTypeValue = "Passager";
    }
    return accountTypeValue;
  }
}
