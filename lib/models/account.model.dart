/**
 * @created 20/10/2023 - 23:11
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/cupertino.dart';

class AccountModel extends ChangeNotifier {
  String _id;
  String? accountId;
  int? accountType;
  String? password;
  String? passwordConfirmation;
  String? phoneNumber;
  int? status;
  String? token;

  AccountModel(
    this._id, {
    this.accountId,
    this.accountType,
    this.password,
    this.passwordConfirmation,
    this.phoneNumber,
    this.status,
    this.token,
  });

  String get id {
    return _id;
  }

  void setId(String _id) {
    this._id = _id;
  }

  String? get getAccountId {
    return accountId != null ? accountId : '';
  }

  void setAccountId(String accountId) {
    this.accountId = accountId;
  }

  int? get getAccountType {
    return accountType != null ? accountType : 0;
  }

  void setAccountType(int accountType) {
    this.accountType = accountType;
  }

  String? get getPassword {
    return password != null ? password : '';
  }

  void setPassword(String password) {
    this.password = password;
  }

  String? get getPasswordConfirmation {
    return passwordConfirmation != null ? passwordConfirmation : '';
  }

  void setPasswordConfirmation(String passwordConfirmation) {
    this.passwordConfirmation = passwordConfirmation;
  }

  String? get getPhoneNumber {
    return phoneNumber != null ? phoneNumber : '';
  }

  void setPhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
  }

  int? get getStatus {
    return status != null ? status : 0;
  }

  void setStatus(int status) {
    this.status = status;
  }

  String? get getToken {
    return token != null ? token : '';
  }

  void setToken(String token) {
    this.token = token;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'accountId': accountId,
      'accountType': accountType,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
      'phoneNumber': phoneNumber,
      'status': status,
      'token': token,
    };
  }

  void updateAccountData(Map<String, dynamic> accountData) {
    _id = accountData['_id'];
    accountId = accountData['accountId'];
    accountType = accountData['accountType'];
    password = accountData['password'];
    passwordConfirmation = accountData['passwordConfirmation'];
    phoneNumber = accountData['phoneNumber'];
    status = accountData['status'];
    token = accountData['token'];
    notifyListeners();
  }
}
