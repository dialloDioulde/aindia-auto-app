/**
 * @created 03/11/2023 - 00:24
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/cupertino.dart';

import '../account.model.dart';

class IdentityModel extends ChangeNotifier {
  String _id;
  AccountModel account;
  String? drivingLicense;
  String firstname;
  String lastname;

  IdentityModel(this._id, this.account, this.firstname, this.lastname,
      {this.drivingLicense});

  String get id {
    return _id;
  }

  void setId(String _id) {
    this._id = _id;
  }

  AccountModel get getAccount {
    return this.account;
  }

  void setAccount(AccountModel account) {
    this.account = account;
  }

  String? get getDrivingLicense {
    return this.drivingLicense != null ? this.drivingLicense : '';
  }

  void setDrivingLicense(String drivingLicense) {
    this.drivingLicense = drivingLicense;
  }

  String get getFirstname {
    return this.firstname;
  }

  void setFirstname(String firstname) {
    this.firstname = firstname;
  }

  String get getLastname {
    return this.lastname;
  }

  void setLastname(String lastname) {
    this.lastname = lastname;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'account': account,
      'drivingLicense': drivingLicense,
      'firstname': firstname,
      'lastname': lastname,
    };
  }

  void updateModelData(Map<String, dynamic> modelData) {
    _id = modelData['_id'];
    account = modelData['account'];
    drivingLicense = modelData['drivingLicense'];
    firstname = modelData['firstname'];
    lastname = modelData['lastname'];
    notifyListeners();
  }
}
