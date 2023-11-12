/**
 * @created 11/11/2023 - 00:39
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../services/config/config.service.dart';


class MapOrder extends StatefulWidget {
  const MapOrder({Key? key}) : super(key: key);

  @override
  _MapOrderState createState() => _MapOrderState();
}

class _MapOrderState extends State<MapOrder> {
  ConfigService configService = ConfigService();
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  double startLatitude = 45.521563;
  double startLongitude = -122.677433;
  double? endLatitude;
  double? endLongitude;

  List _placeList = [];
  TextEditingController searchController = TextEditingController();

  late TextEditingController _sourceLocationController =
  TextEditingController(text: '');
  late TextEditingController _destinationController =
  TextEditingController(text: '');

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    //mapController.moveCamera(cameraUpdate)
  }
  //LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  //GoogleMapController? _controller;
  //Location _location = Location();

  /*void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
        ),
      );
    });
  }*/


  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      double lat = position.latitude;
      double long = position.longitude;
      LatLng location = LatLng(lat, long);
      print(location);
      setState(() {
        startLatitude = location.latitude;
        startLongitude = location.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isListClosed = false;


  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [
      TextField(
        controller: _sourceLocationController,
        decoration: InputDecoration(
          labelText: 'Départ',
          suffixIcon: Icon(Icons.cancel),
        ),
        onChanged: (value) {
          // Handle autocomplete suggestions here
          // You can make an API call to Google Places Autocomplete
          setState(() {
            isListClosed = false;
          });
        },
      ),
      if (!isListClosed) ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: _placeList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text(_placeList[index]['description']), onTap: () {
            // Handle tap event here
            print('Row $index tapped!');
            _sourceLocationController.text = _placeList[index]['description'];
            setState(() {
              isListClosed = true;
            });
          },);
        },
      ),
      SizedBox(
          //height: 250,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(2.00),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              //markers: _markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(startLatitude, startLongitude),
                zoom: 8,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ))
    ],),);
  }

  /*@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        /*appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),*/
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          //markers: _markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(startLatitude, startLongitude),
            zoom: 8,
          ),
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }*/

  /*@override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [
      TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search Places',
          suffixIcon: Icon(Icons.cancel),
        ),
        onChanged: (value) {
          // Handle autocomplete suggestions here
          // You can make an API call to Google Places Autocomplete
          setState(() {
            isListClosed = false;
          });
        },
      ),
      if (!isListClosed) ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: _placeList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text(_placeList[index]['description']), onTap: () {
            // Handle tap event here
            print('Row $index tapped!');
            searchController.text = _placeList[index]['description'];
            setState(() {
              isListClosed = true;
            });
          },);
        },
      ),
      SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(2.00),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              //markers: _markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(startLatitude, startLongitude),
                zoom: 8,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ))
    ],),);
  }*/

  /*
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //height: 300,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: EdgeInsets.all(10.00),
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            //markers: _markers,
            initialCameraPosition: CameraPosition(
              target: LatLng(46.60, -71.89),
              zoom: 10,
            ),
            mapType: MapType.normal,
          ),
        ));
  }*/
}
