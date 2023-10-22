/**
 * @created 21/10/2023 - 23:30
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:flutter/cupertino.dart';
import '../map/map-position.model.dart';

class OrderModel extends ChangeNotifier {
  String _id;
  int? datetime;
  MapPositionModel? destinationLocation;
  int? distance;
  AccountModel? driver;
  AccountModel? passenger;
  int? price;
  MapPositionModel? sourceLocation;
  int? status;

  OrderModel(
    this._id, {
    this.datetime,
    this.destinationLocation,
    this.distance,
    this.driver,
    this.passenger,
    this.price,
    this.sourceLocation,
    this.status,
  });

  String get id {
    return _id;
  }

  void setId(String _id) {
    this._id = _id;
  }

  int? get getDatetime {
    return datetime != null ? datetime : -1;
  }

  void setDatetime(int datetime) {
    this.datetime = datetime;
  }

  Object? get getDestinationLocation {
    return destinationLocation != null ? destinationLocation : {};
  }

  void setDestinationLocation(MapPositionModel destinationLocation) {
    this.destinationLocation = destinationLocation;
  }

  int? get getDistance {
    return distance != null ? distance : -1;
  }

  void setDistance(int distance) {
    this.distance = distance;
  }

  Object? get getDriver {
    return driver != null ? driver : {};
  }

  void setDriver(AccountModel driver) {
    this.driver = driver;
  }

  Object? get getPassenger {
    return passenger != null ? passenger : {};
  }

  void setPassenger(AccountModel passenger) {
    this.passenger = passenger;
  }

  int? get getPrice {
    return price != null ? price : -1;
  }

  void setPrice(int price) {
    this.price = price;
  }

  Object? get getSourceLocation {
    return sourceLocation != null ? sourceLocation : {};
  }

  void setSourceLocation(MapPositionModel sourceLocation) {
    this.sourceLocation = sourceLocation;
  }

  int? get getStatus {
    return status != null ? status : 0;
  }

  void setStatus(int status) {
    this.status = status;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'datetime': datetime,
      'destinationLocation': destinationLocation,
      'distance': distance,
      'driver': driver,
      'passenger': passenger,
      'price': price,
      'sourceLocation': sourceLocation,
      'status': status,
    };
  }

  void updateOrderData(Map<String, dynamic> accountData) {
    _id = accountData['_id'];
    datetime = accountData['datetime'];
    destinationLocation = accountData['destinationLocation'];
    distance = accountData['distance'];
    driver = accountData['driver'];
    passenger = accountData['passenger'];
    price = accountData['price'];
    sourceLocation = accountData['sourceLocation'];
    status = accountData['status'];
    notifyListeners();
  }
}
