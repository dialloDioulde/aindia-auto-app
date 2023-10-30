/**
 * @created 29/10/2023 - 16:14
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/models/driver-position/driver-position.model.dart';
import 'package:aindia_auto_app/models/driver-position/driver-status.enum.dart';
import 'package:aindia_auto_app/services/driver-position/driver-position.service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../models/account.model.dart';
import '../../models/map/map-position.model.dart';
import '../../services/config/config.service.dart';
import '../../utils/constants.dart';
import '../../utils/dates/dates.util.dart';
import '../../utils/google-map.util.dart';
import '../../utils/shared-preferences.util.dart';

class AccountComponent extends StatefulWidget {
  const AccountComponent({super.key});

  @override
  State<AccountComponent> createState() => AccountState();
}

class AccountState extends State<AccountComponent> {
  AccountModel accountModel = AccountModel('');
  MapPositionModel? positionModel;

  GoogleMapUtil googleMapUtil = GoogleMapUtil();
  DatesUtil datesUtil = DatesUtil();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  Constants constants = Constants();

  DriverPositionService driverPositionService = DriverPositionService();
  ConfigService configService = ConfigService();

  DriverPositionStatus driverPositionStatus = DriverPositionStatus();

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting("fr_FR", null);
  }

  _displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  Future<void> _initializeData() async {
    _datesConfiguration();
    accountModel = await sharedPreferencesUtil.getAccountDataFromToken();
    _getCurrentPosition();
  }

  _getCurrentPosition() async {
    try {
      Position position = await googleMapUtil.determinePosition();
      setState(() {
        positionModel = MapPositionModel(position.latitude, position.longitude);
      });
      _createOrUpdateDriverPosition();
    } catch (error) {
      _displayMessage(
          'Attention vous devez activer la géolocalisation pour pouvoir travailler !',
          Colors.red);
    }
  }

  void _createOrUpdateDriverPosition() async {
    String currentTime =
        datesUtil.getCurrentTime('Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');
    int datetime = datesUtil.convertDateTimeToMilliseconds(
        currentTime, 'Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');

    DriverPositionModel driverPositionModel = DriverPositionModel(
        '',
        datetime,
        accountModel,
        positionModel!,
        driverPositionStatus
            .driverPositionStatusValue(DriverPositionStatusEnum.AVAILABLE));

    await driverPositionService
        .createOrUpdateDriverPosition(driverPositionModel)
        .then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
      }
      if (response.statusCode == 422) {}
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    //_initializeData();
  }

  @override
  void dispose() {
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
              'Mon Compte',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ))),
    );
  }
}
