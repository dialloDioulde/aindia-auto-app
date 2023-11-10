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
  String? destinationLocationText;
  double? distance;
  AccountModel? driver;
  AccountModel? passenger;
  double? price;
  MapPositionModel? sourceLocation;
  String? sourceLocationText;
  int? status;

  OrderModel(
    this._id, {
    this.datetime,
    this.destinationLocation,
    this.destinationLocationText,
    this.distance,
    this.driver,
    this.passenger,
    this.price,
    this.sourceLocation,
    this.sourceLocationText,
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

  String? get getDestinationLocationText {
    return destinationLocationText != null ? destinationLocationText : '';
  }

  void setDestinationLocationText(String destinationLocationText) {
    this.destinationLocationText = destinationLocationText;
  }

  double? get getDistance {
    return distance != null ? distance : -1;
  }

  void setDistance(double distance) {
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

  double? get getPrice {
    return price != null ? price : -1;
  }

  void setPrice(double price) {
    this.price = price;
  }

  Object? get getSourceLocation {
    return sourceLocation != null ? sourceLocation : {};
  }

  void setSourceLocation(MapPositionModel sourceLocation) {
    this.sourceLocation = sourceLocation;
  }

  String? get getSourceLocationText {
    return sourceLocationText != null ? sourceLocationText : '';
  }

  void setSourceLocationText(String sourceLocationText) {
    this.sourceLocationText = sourceLocationText;
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
      'destinationLocationText': destinationLocationText,
      'distance': distance,
      'driver': driver,
      'passenger': passenger,
      'price': price,
      'sourceLocation': sourceLocation,
      'sourceLocationText': sourceLocationText,
      'status': status,
    };
  }

  void updateOrderData(Map<String, dynamic> accountData) {
    _id = accountData['_id'];
    datetime = accountData['datetime'];
    destinationLocation = accountData['destinationLocation'];
    destinationLocationText = accountData['destinationLocationText'];
    distance = accountData['distance'];
    driver = accountData['driver'];
    passenger = accountData['passenger'];
    price = accountData['price'];
    sourceLocation = accountData['sourceLocation'];
    sourceLocationText = accountData['sourceLocationText'];
    status = accountData['status'];
    notifyListeners();
  }
}
