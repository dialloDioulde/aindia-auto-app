/**
 * @created 21/10/2023 - 23:30
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:flutter/cupertino.dart';
import '../map/map-position.model.dart';

class DriverPositionModel extends ChangeNotifier {
  String _id;
  int datetime;
  AccountModel driver;
  MapPositionModel position;
  int status;

  DriverPositionModel(
    this._id,
    this.datetime,
    this.driver,
    this.position,
    this.status,
  );

  String get id {
    return _id;
  }

  void setId(String _id) {
    this._id = _id;
  }

  int get getDatetime {
    return datetime;
  }

  void setDatetime(int datetime) {
    this.datetime = datetime;
  }

  Object get getDriver {
    return driver;
  }

  void setDriver(AccountModel driver) {
    this.driver = driver;
  }

  Object get getPosition {
    return position;
  }

  void setPosition(MapPositionModel position) {
    this.position = position;
  }

  int get getStatus {
    return status;
  }

  void setStatus(int status) {
    this.status = status;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'datetime': datetime,
      'driver': driver,
      'position': position,
      'status': status,
    };
  }

  void updateOrderData(Map<String, dynamic> driverPosition) {
    _id = driverPosition['_id'];
    datetime = driverPosition['datetime'];
    driver = driverPosition['driver'];
    position = driverPosition['position'];
    status = driverPosition['status'];
    notifyListeners();
  }
}
