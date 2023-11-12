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
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:aindia_auto_app/models/map/map-position.model.dart';
import 'package:aindia_auto_app/models/order/order.model.dart';
import 'package:aindia_auto_app/services/order/order.service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
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

  double? _startLatitude;
  double? _startLongitude;
  double? _endLatitude;
  double? _endLongitude;

  bool _requestIsRunning = false;

  late TextEditingController _sourceLocationController =
      TextEditingController(text: '');
  late TextEditingController _destinationController =
      TextEditingController(text: '');

  _sourceLocationACPTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _sourceLocationController,
        googleAPIKey: configService.googleApiKey,
        inputDecoration: InputDecoration(
          hintText: "Départ",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: constants.GOOGLE_MAP_COUNTRIES,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            _startLatitude = double.parse(prediction.lat!);
            _startLongitude = double.parse(prediction.lng!);
          });
        },
        itemClick: (Prediction prediction) {
          _sourceLocationController.text = prediction.description ?? "";
          _sourceLocationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
        // default 600 ms ,
      ),
    );
  }

  _destinationACPTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _destinationController,
        googleAPIKey: configService.googleApiKey,
        inputDecoration: InputDecoration(
          hintText: "Destination",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: constants.GOOGLE_MAP_COUNTRIES,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            _endLatitude = double.parse(prediction.lat!);
            _endLongitude = double.parse(prediction.lng!);
          });
        },
        itemClick: (Prediction prediction) {
          _destinationController.text = prediction.description ?? "";
          _destinationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
        // default 600 ms ,
      ),
    );
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      double lat = position.latitude;
      double long = position.longitude;
      LatLng location = LatLng(lat, long);
      setState(() {
        _startLatitude = location.latitude;
        _startLongitude = location.longitude;
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
        child: ElevatedButton(
          child: Text(
            "RECHERCHER",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          onPressed: _generalValidations() &&
                  orderData.length <= 0 &&
                  !_requestIsRunning
              ? () {
                  _createOrder();
                }
              : null,
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
    this._resetValidations(true);
    MapPositionModel sourceLocation =
        MapPositionModel(_startLatitude, _startLongitude);
    MapPositionModel destinationLocation =
        MapPositionModel(_endLatitude, _endLongitude);

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
    setState(() {
      _requestIsRunning = value;
    });
  }

  displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  bool _generalValidations() {
    return _sourceLocationController.text.trim().isNotEmpty &&
        _startLatitude != null &&
        _startLongitude != null &&
        _endLatitude != null &&
        _endLongitude != null &&
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
    // Fields controller
    _sourceLocationController.addListener(() {
      if (_sourceLocationController.text.trim().isEmptyOrNull) {
        setState(() {
          _startLatitude = null;
          _startLongitude = null;
        });
      }
    });
    _destinationController.addListener(() {
      if (_destinationController.text.trim().isEmptyOrNull) {
        setState(() {
          _endLatitude = null;
          _endLongitude = null;
        });
      }
    });
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
          SizedBox(height: 20),
          _destinationACPTextField(),
          SizedBox(height: 30),
          _orderButton(),
        ],
      ),
    );
  }
}
