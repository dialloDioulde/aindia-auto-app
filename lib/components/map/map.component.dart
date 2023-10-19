/**
 * @created 14/10/2023 - 17:23
 * @project aindia_auto_app
 * @author mamadoudiallo
 */


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../utils/google-map.util.dart';

class MapComponent extends StatelessWidget {
  const MapComponent({Key? key}) : super(key: key);

  static const String _title = 'Aindia Auto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(_title),
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
        ),
        body: const MapSample(),
        backgroundColor: Colors.white);
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(46.8122, -71.1836);
  LatLng _sourcePosition = LatLng(46.8122, -71.1836);
  LatLng _destinationPosition = LatLng(46.815412416445625, -71.18197316849692);
  List<LatLng> polylineCoordinates = [];
  String startLatitude = "";
  String startLongitude = "";
  String endLatitude = "";
  String endLongitude = "";
  String distance = "00.00";
  double price = 00.00;

  late TextEditingController _currentLocationController =
      TextEditingController(text: '');
  late TextEditingController _destinationController =
      TextEditingController(text: '');

  GoogleMapUtil googleMapUtil = GoogleMapUtil();

  currentLocationACPTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: _currentLocationController,
        googleAPIKey: "AIzaSyDLKwz0Fih_MKYU5nbn2MmJjGyYzTtug_E",
        inputDecoration: InputDecoration(
          hintText: "Départ",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: [
          "sn",
          "fr",
          "ca",
          "ci",
          "gm",
        ],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            startLatitude = prediction.lat!.toString();
            startLongitude = prediction.lng!.toString();
          });
        },
        itemClick: (Prediction prediction) {
          _currentLocationController.text = prediction.description ?? "";
          _currentLocationController.selection = TextSelection.fromPosition(
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
        googleAPIKey: "AIzaSyDLKwz0Fih_MKYU5nbn2MmJjGyYzTtug_E",
        inputDecoration: InputDecoration(
          hintText: "Arrivé",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: [
          "sn",
          "fr",
          "ca",
          "ci",
          "gm",
        ],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            endLatitude = prediction.lat!.toString();
            endLongitude = prediction.lng!.toString();
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
    if (startLatitude.isNotEmptyAndNotNull &&
        startLongitude.isNotEmptyAndNotNull &&
        endLatitude.isNotEmptyAndNotNull &&
        endLongitude.isNotEmptyAndNotNull) {
      setState(() {
        distance = googleMapUtil
            .distanceBetween(
                double.parse(startLatitude),
                double.parse(startLongitude),
                double.parse(endLatitude),
                double.parse(endLongitude))
            .toString();
        distance = convertMetersInKm(double.parse(distance)).toString();
        calculatePrice();
      });
    }
    return "Distance : " + distance + " KM";
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
      price = double.parse(distance) * 580.00;
    }
    if (int.parse(formattedHour) >= 13 && int.parse(formattedHour) <= 16) {
      price = double.parse(distance) * 550.00;
    }
    if (int.parse(formattedHour) >= 16 && int.parse(formattedHour) <= 21) {
      price = double.parse(distance) * 700.00;
    }
    if (int.parse(formattedHour) >= 21 && int.parse(formattedHour) <= 23) {
      price = double.parse(distance) * 810.00;
    }
    if (int.parse(formattedHour) >= 0 && int.parse(formattedHour) <= 8) {
      price = double.parse(distance) * 850.00;
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
        _currentPosition = location;
        print('CURRENT POS: $_currentPosition');
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
      onPressed: () {},
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getPolyPoints();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
          child: Center(
              child: Center(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
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
            Text(
              calculateDistanceBetweenPoints(),
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              displayPrice(price),
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            _launchOrderButton(),
          ],
        ),
      ))),
    );

    /*return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                width: width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      Text(
                        calculateDistanceBetweenPoints(),
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        displayPrice(price),
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      _launchOrderButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    )));*/
  }
}
