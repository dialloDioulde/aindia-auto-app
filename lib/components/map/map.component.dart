/**
 * @created 14/10/2023 - 17:23
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:async';
import 'dart:convert';
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
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web_socket_channel/io.dart';
import '../../models/account.model.dart';
import '../../models/order/order-status.enum.dart';
import '../../services/socket/websocket.service.dart';
import '../../utils/dates/dates.util.dart';
import '../../utils/google-map.util.dart';

class MapComponent extends StatefulWidget {
  const MapComponent({super.key});

  @override
  State<MapComponent> createState() => MapState();
}

class MapState extends State<MapComponent> {
  AccountModel accountModel = AccountModel('');
  OrderModel orderModel = OrderModel('');

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
  double distance = 00.00;
  double price = 00.00;

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

  String calculateDistanceBetweenPoints() {
    if (startLatitude != null &&
        startLongitude != null &&
        endLatitude != null &&
        endLongitude != null) {
      setState(() {
        distance = googleMapUtil.distanceBetween(
            startLatitude!, startLongitude!, endLatitude!, endLongitude!);
        distance = convertMetersInKm(double.parse(distance.toString()));
        calculatePrice();
      });
    }
    return "Distance : " + distance.toString() + " KM";
  }

  double convertMetersInKm(double distanceInMeters) {
    double distanceInKiloMeters = distanceInMeters / 1000;
    return double.parse((distanceInKiloMeters).toStringAsFixed(2));
  }

  void calculatePrice() {
    // Get the current date and time
    DateTime now = DateTime.now();
    String formattedHour = DateFormat('HH').format(now);

    if (int.parse(formattedHour) >= 8 && int.parse(formattedHour) <= 12) {
      price = double.parse(distance.toString()) * 580.00;
    }
    if (int.parse(formattedHour) >= 13 && int.parse(formattedHour) <= 16) {
      price = double.parse(distance.toString()) * 550.00;
    }
    if (int.parse(formattedHour) >= 16 && int.parse(formattedHour) <= 21) {
      price = double.parse(distance.toString()) * 700.00;
    }
    if (int.parse(formattedHour) >= 21 && int.parse(formattedHour) <= 23) {
      price = double.parse(distance.toString()) * 810.00;
    }
    if (int.parse(formattedHour) >= 0 && int.parse(formattedHour) <= 8) {
      price = double.parse(distance.toString()) * 850.00;
    }

    // Convert the double to a string.
    String stringValue = price.toString();
    // Find the index of the decimal point.
    int decimalIndex = stringValue.indexOf('.');
    // If there is a decimal point, replace the characters after it with "00".
    if (decimalIndex != -1) {
      int charactersToReplace = stringValue.length - (decimalIndex + 1);
      String newValue = stringValue.replaceRange(
          decimalIndex + 1, decimalIndex + 1 + charactersToReplace, '00');
      price = double.parse(newValue);
    }
  }

  String displayPrice(double price) {
    return "Prix : " + price.toString();
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

  Widget _launchOrderButton() {
    return ElevatedButton(
      onPressed: () {
        _createOrder();
      },
      child: const Text(
        'Commander',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting("fr_FR", null);
  }

  void _createOrder() async {
    MapPositionModel sourceLocation =
        MapPositionModel(startLatitude, startLongitude);
    MapPositionModel destinationLocation =
        MapPositionModel(endLatitude, endLongitude);

    String currentTime =
        datesUtil.getCurrentTime('Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');
    int datetime = datesUtil.convertDateTimeToMilliseconds(
        currentTime, 'Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');

    this.orderModel = OrderModel('',
        datetime: datetime,
        sourceLocation: sourceLocation,
        destinationLocation: destinationLocation,
        distance: distance,
        passenger: this.accountModel,
        price: price,
        status: orderStatus.orderStatusValue(OrderStatusEnum.PENDING));

    await orderService.createOrder(orderModel).then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print(body);
      }
      if (response.statusCode == 422) {
        displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      this._resetValidations(false);
      displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  _resetValidations(bool value) {}

  bool generalValidations() {
    return startLatitude != null &&
        startLongitude != null &&
        endLatitude != null &&
        endLongitude != null;
  }

  _initializeData() async {
    _datesConfiguration();
    accountModel = Provider.of<AccountModel>(context, listen: false);
    // Map
    _getCurrentLocation(); // TODO
    _getPolyPoints(); // TODO
    // Web Socket
    final event = {
      'action': "createRoom",
      'roomId': accountModel.id,
    };
    webSocketService.sendMessageWebSocket(channel, event);

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
    return Center(
      child: SingleChildScrollView(
          child: Center(
              child: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Course',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 10),
            currentLocationACPTextField(),
            SizedBox(height: 10),
            destinationACPTextField(),
            SizedBox(height: 12),
            if (generalValidations())
              Text(
                calculateDistanceBetweenPoints(),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            if (generalValidations()) SizedBox(height: 12),
            if (generalValidations())
              Text(
                displayPrice(price),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            if (generalValidations()) SizedBox(height: 12),
            if (generalValidations()) _launchOrderButton(),
          ],
        ),
      ))),
    );
  }
}
