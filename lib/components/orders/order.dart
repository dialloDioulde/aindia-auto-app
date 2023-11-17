/**
 * @created 07/11/2023 - 22:34
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:async';
import 'package:aindia_auto_app/components/orders/create.order.dart';
import 'package:aindia_auto_app/components/orders/process.order.dart';
import 'package:aindia_auto_app/models/driver-position/driver-position.model.dart';
import 'package:aindia_auto_app/services/config/config.service.dart';
import 'package:aindia_auto_app/utils/constants.dart';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:aindia_auto_app/models/order/order.model.dart';
import 'package:aindia_auto_app/services/order/order.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web_socket_channel/io.dart';
import '../../models/account.model.dart';
import '../../models/order/order-status.enum.dart';
import '../../services/socket/websocket.service.dart';
import '../../utils/dates/dates.util.dart';
import '../../utils/google-map.util.dart';
import '../card/order.driver.card.dart';
import 'details.order.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => OrderState();
}

class OrderState extends State<Order> {
  AccountModel accountModel = AccountModel('');
  OrderModel orderModel = OrderModel('');
  DriverPositionModel? driverPositionModel;
  List orderData = [];
  List orderDataList = [];

  int _orderStep = 1;
  var _orderDriverSelected;

  GoogleMapUtil googleMapUtil = GoogleMapUtil();
  DatesUtil datesUtil = DatesUtil();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  Constants constants = Constants();

  ConfigService configService = ConfigService();
  OrderService orderService = OrderService();

  OrderStatus orderStatus = OrderStatus();

  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  Timer? heartbeatTimer;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;
  LatLng _sourcePosition = LatLng(46.8122, -71.1836);
  LatLng _destinationPosition = LatLng(46.815412416445625, -71.18197316849692);
  List<LatLng> polylineCoordinates = [];

  double? startLatitude;
  double? startLongitude;
  double? endLatitude;
  double? endLongitude;

  late TextEditingController _sourceLocationController =
      TextEditingController(text: '');
  late TextEditingController _destinationController =
      TextEditingController(text: '');

  String _onTextChanged(fieldController) {
    return fieldController.text;
  }

  currentLocationACPTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
            startLatitude = double.parse(prediction.lat!);
            startLongitude = double.parse(prediction.lng!);
          });
        },
        itemClick: (Prediction prediction) {
          _sourceLocationController.text = prediction.description ?? "";
          _sourceLocationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        // OPTIONAL// If you want to customize list view item builder
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

  destinationACPTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _destinationController,
        googleAPIKey: configService.googleApiKey,
        inputDecoration: InputDecoration(
          hintText: "Arrivé",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: constants.GOOGLE_MAP_COUNTRIES,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            endLatitude = double.parse(prediction.lat!);
            endLongitude = double.parse(prediction.lng!);
          });
        },
        itemClick: (Prediction prediction) {
          _destinationController.text = prediction.description ?? "";
          _destinationController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        // OPTIONAL// If you want to customize list view item builder
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
        startLatitude = location.latitude;
        startLongitude = location.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  void _getPolyPoints() async {
    const googleApiKey = 'AIzaSyDLKwz0Fih_MKYU5nbn2MmJjGyYzTtug_E';
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey,
            PointLatLng(_sourcePosition.latitude, _sourcePosition.longitude),
            PointLatLng(
                _destinationPosition.latitude, _destinationPosition.longitude));

    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
    }
  }

  Widget _cancelOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          child: Text(
            "ANNULER",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _cancelOrder();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.red,
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

  void _cancelOrder() async {
    final orderJson = {
      '_id': orderData[0]['order']['_id'],
      'order': orderData[0]['order'],
    };
    await orderService.cancelOrder(orderJson).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          orderData = [];
          orderDataList = [];
        });
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

  bool generalValidations() {
    return startLatitude != null &&
        startLongitude != null &&
        endLatitude != null &&
        endLongitude != null;
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
    _getPolyPoints();

    // Fields controller
    _sourceLocationController.addListener(() {
      final newText = _onTextChanged(_sourceLocationController);
      if (newText.isEmptyOrNull) {
        setState(() {
          startLatitude = null;
          startLongitude = null;
        });
        this.generalValidations();
      }
    });
    _destinationController.addListener(() {
      final newText = _onTextChanged(_destinationController);
      if (newText.isEmptyOrNull) {
        setState(() {
          endLatitude = null;
          endLongitude = null;
        });
        this.generalValidations();
      }
    });
  }

  // Callback function to receive data from the child
  void onDataFromChild(List data) {
    setState(() {
      orderData = data;
      for (var obj in orderData) {
        setState(() {
          orderDataList.add(obj);
        });
      }
    });
  }

  void onDataFromOrderDriver(int value, dynamic orderDriverSelected) {
    setState(() {
      _orderStep = value;
      _orderDriverSelected = orderDriverSelected;
    });
  }

  void onDataFromProcessOrder(int value) {
    print('onDataFromProcessOrder : $value');
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
      child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                // Create Order
                if (_orderStep == 1 && orderDataList.length <= 0)
                  CreateOrder(
                    onDataReceived: onDataFromChild,
                  ),

                // Order Driver details
                if (_orderStep == 1 && orderDataList.length > 0)
                  Text(
                    'Taxis Disponibles',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (_orderStep == 1 && orderDataList.length > 0) OrderDriver(data: orderDataList, onDataReceived: onDataFromOrderDriver,),
                if (_orderStep == 1 && orderDataList.length > 0)
                  DetailsOrder(
                    onDataReceived: onDataFromChild,
                    orderDataList: orderDataList,
                  ),
                if (_orderStep == 1 && orderDataList.length > 0) _cancelOrderButton(),

                // Process Order
                if (_orderStep == 3) ProcessOrder(orderDriverSelected: _orderDriverSelected, onDataReceived: onDataFromProcessOrder,),
              ],
            )),
      ),
    );
  }
}
