/**
 * @created 10/11/2023 - 13:38
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/models/driver-position/driver-position.model.dart';
import 'package:aindia_auto_app/services/config/config.service.dart';
import 'package:aindia_auto_app/utils/constants.dart';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:aindia_auto_app/models/map/map-position.model.dart';
import 'package:aindia_auto_app/models/order/order.model.dart';
import 'package:aindia_auto_app/services/order/order.service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/account.model.dart';
import '../../models/order/order-status.enum.dart';
import '../../utils/dates/dates.util.dart';
import '../../utils/google-map.util.dart';

class CreateOrder extends StatefulWidget {
  final Function(List) onDataReceived;

  CreateOrder({required this.onDataReceived, super.key});

  @override
  State<CreateOrder> createState() => CreateOrderState();
}

class CreateOrderState extends State<CreateOrder> {
  AccountModel accountModel = AccountModel('');
  OrderModel orderModel = OrderModel('');
  DriverPositionModel? driverPositionModel;
  List orderData = [];
  List orderDataList = [];

  GoogleMapUtil googleMapUtil = GoogleMapUtil();
  DatesUtil datesUtil = DatesUtil();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  Constants constants = Constants();

  ConfigService configService = ConfigService();
  OrderService orderService = OrderService();

  OrderStatus orderStatus = OrderStatus();

  double? startLatitude;
  double? startLongitude;
  double? endLatitude;
  double? endLongitude;

  List _placeListSL = [];
  List _placeListDL = [];
  bool isListClosedSL = false;
  bool isListClosedDL = false;

  late TextEditingController _sourceLocationController =
      TextEditingController(text: '');
  late TextEditingController _destinationController =
      TextEditingController(text: '');

  Widget _sourceLocationACPTextField() {
    return TextField(
      controller: _sourceLocationController,
      decoration: InputDecoration(
          labelText: 'Départ',
          suffixIcon: _sourceLocationController.text.trim().isNotEmpty
              ? InkWell(
                  child: Icon(
                    Icons.close,
                  ),
                  onTap: () {
                    setState(() {
                      _sourceLocationController.text = '';
                      startLatitude = null;
                      startLongitude = null;
                    });
                  },
                )
              : null,
          labelStyle: TextStyle(
            fontSize: 19.0,
            color: Colors.black,
          )),
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      onChanged: (value) async {
        if (value.trim().isNotEmpty) {
          // Get place
          var places = await googleMapUtil.placeAutoComplete(value);
          if (places.length > 0) {
            setState(() {
              _placeListSL = places;
              isListClosedSL = false;
            });
          }
          // Get coordinates from address
          var coordinates =
              await googleMapUtil.getCoordinatesFromAddress(value);
          if (coordinates != null) {
            setState(() {
              startLatitude = coordinates['latitude'];
              startLongitude = coordinates['longitude'];
            });
          }
        } else {
          setState(() {
            _placeListSL = [];
            isListClosedSL = false;
            startLatitude = null;
            startLongitude = null;
          });
        }
      },
    );
  }

  Widget _destinationACPTextField() {
    return TextField(
      controller: _destinationController,
      decoration: InputDecoration(
          labelText: 'Destination',
          suffixIcon: _destinationController.text.trim().isNotEmpty
              ? InkWell(
                  child: Icon(
                    Icons.close,
                  ),
                  onTap: () {
                    setState(() {
                      _destinationController.text = '';
                      endLatitude = null;
                      endLongitude = null;
                    });
                  },
                )
              : null,
          labelStyle: TextStyle(
            fontSize: 19.0,
            color: Colors.black,
          )),
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      onChanged: (value) async {
        if (value.trim().isNotEmpty) {
          // Get place
          var places = await googleMapUtil.placeAutoComplete(value);
          if (places.length > 0) {
            setState(() {
              _placeListDL = places;
              isListClosedDL = false;
            });
          }
          // Get coordinates from address
          var coordinates =
              await googleMapUtil.getCoordinatesFromAddress(value);
          if (coordinates != null) {
            setState(() {
              endLatitude = coordinates['latitude'];
              endLongitude = coordinates['longitude'];
            });
          }
        } else {
          setState(() {
            _placeListDL = [];
            isListClosedDL = false;
            endLatitude = null;
            endLongitude = null;
          });
        }
      },
    );
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      double lat = position.latitude;
      double long = position.longitude;
      LatLng location = LatLng(lat, long);
      setState(() {
        startLatitude = location.latitude;
        startLongitude = location.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget _orderButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        //height: 50,
        child: ElevatedButton(
          child: Text(
            "RECHERCHER",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _createOrder();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting(constants.FR_FR, null);
  }

  void _createOrder() async {
    MapPositionModel sourceLocation =
        MapPositionModel(startLatitude, startLongitude);
    MapPositionModel destinationLocation =
        MapPositionModel(endLatitude, endLongitude);

    String currentTime = datesUtil.getCurrentTime(
        constants.AFRICA_DAKAR, constants.YYYY_MM_DD_HH_MM_SS);
    int datetime = datesUtil.convertDateTimeToMilliseconds(
        currentTime, constants.AFRICA_DAKAR, constants.YYYY_MM_DD_HH_MM_SS);

    var accountJson = {
      '_id': accountModel.id,
      'accountId': accountModel.accountId,
      'accountType': accountModel.accountType,
      'phoneNumber': accountModel.phoneNumber,
      'status': accountModel.status,
    };

    var orderJson = {
      'datetime': datetime,
      'sourceLocation': sourceLocation,
      'sourceLocationText': _sourceLocationController.text,
      'destinationLocation': destinationLocation,
      'destinationLocationText': _destinationController.text,
      'distance': 00.00,
      'passenger': accountJson,
      'price': 00.00,
      'status': orderStatus.orderStatusValue(OrderStatusEnum.PENDING)
    };

    await orderService.createOrder(orderJson).then((response) {
      setState(() {
        orderData = [];
        orderDataList = [];
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['orderData'].length > 0) {
          setState(() {
            orderData = jsonData['orderData'];
          });
        }
        // Send data to parent
        widget.onDataReceived(orderData);
      }
      if (response.statusCode == 422) {
        this._resetValidations(false);
        displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      this._resetValidations(false);
      displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  _resetValidations(bool value) {
    setState(() {});
  }

  displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  bool _generalValidations() {
    return _sourceLocationController.text.trim().isNotEmpty &&
        startLatitude != null &&
        startLongitude != null &&
        endLatitude != null &&
        endLongitude != null &&
        _destinationController.text.trim().isNotEmpty;
  }

  _initializeData() async {
    _datesConfiguration();
    setState(() {
      accountModel = Provider.of<AccountModel>(context, listen: false);
      accountModel = AccountModel(accountModel.id,
          accountId: accountModel.accountId,
          accountType: accountModel.accountType,
          identity: accountModel.identity,
          phoneNumber: accountModel.phoneNumber,
          status: accountModel.status,
          token: accountModel.token);
    });
    // Map
    _getCurrentLocation();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _sourceLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Course',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _sourceLocationACPTextField(),
          if (!isListClosedSL)
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _placeListSL.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(11),
                  child: InkWell(
                    onTap: () async {
                      // Re update final values
                      var coordinates =
                          await googleMapUtil.getCoordinatesFromAddress(
                              _sourceLocationController.text);
                      setState(() {
                        startLatitude = coordinates['latitude'];
                        startLongitude = coordinates['longitude'];
                        _sourceLocationController.text =
                            _placeListSL[index]['description'];
                        isListClosedSL = true;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 7,
                        ),
                        Expanded(
                            child: Text(_placeListSL[index]['description']))
                      ],
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: 45),
          _destinationACPTextField(),
          if (!isListClosedDL)
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _placeListDL.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(11),
                  child: InkWell(
                    onTap: () async {
                      // Re update final values
                      var coordinates =
                          await googleMapUtil.getCoordinatesFromAddress(
                              _destinationController.text);
                      setState(() {
                        endLatitude = coordinates['latitude'];
                        endLongitude = coordinates['longitude'];
                        _destinationController.text =
                            _placeListDL[index]['description'];
                        isListClosedDL = true;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 7,
                        ),
                        Expanded(
                            child: Text(_placeListDL[index]['description']))
                      ],
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: 30),
          if (_generalValidations() && orderData.length <= 0) _orderButton(),
        ],
      ),
    );
  }
}
