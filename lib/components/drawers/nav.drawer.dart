/**
 * @created 29/10/2023 - 16:10
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:async';
import 'dart:convert';

import 'package:aindia_auto_app/components/orders/list.order.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web_socket_channel/io.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../models/account-type.enum.dart';
import '../../models/account.model.dart';
import '../../models/driver-position/driver-status.enum.dart';
import '../../models/map/map-position.model.dart';
import '../../services/config/config.service.dart';
import '../../services/driver-position/driver-position.service.dart';
import '../../services/socket/websocket.service.dart';
import '../../utils/constants.dart';
import '../../utils/dates/dates.util.dart';
import '../../utils/google-map.util.dart';
import '../../utils/shared-preferences.util.dart';
import '../account/account.component.dart';
import '../account/login.dart';
import '../orders/order.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  AccountModel accountModel = AccountModel('');
  AccountType accountType = AccountType();
  MapPositionModel? positionModel;

  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();
  DriverPositionService driverPositionService = DriverPositionService();
  ConfigService configService = ConfigService();

  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();
  GoogleMapUtil googleMapUtil = GoogleMapUtil();
  DatesUtil datesUtil = DatesUtil();

  Constants constants = Constants();

  DriverPositionStatus driverPositionStatus = DriverPositionStatus();

  GoogleMapController? mapController;
  StreamSubscription? positionStream;

  Timer? heartbeatTimer;

  String _title = 'Aindia Auto';
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      setState(() {
        _title = "Course";
      });
    }
    if (_selectedIndex == 1) {
      setState(() {
        _title = "Commandes";
      });
    }
    if (_selectedIndex == 2) {
      setState(() {
        _title = "Compte";
      });
    }
  }

  _displayComponentDynamically() {
    if (_selectedIndex == 0) {
      if (accountModel.accountType ==
          accountType.accountTypeValue(AccountTypeEnum.PASSENGER)) {
        return Order();
      } else if (accountModel.accountType ==
          accountType.accountTypeValue(AccountTypeEnum.DRIVER)) {
        return AccountComponent();
      } else {
        return CircularProgressIndicator();
      }
    }
    if (_selectedIndex == 1) {
      return ListOrder();
    }
    if (_selectedIndex == 2) {
      return AccountComponent();
    }
  }

  _displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  Future<void> _initializeData() async {
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
    // Init  Web Socket
    final event = {
      'action': constants.CREATE_ROOM,
      'roomId': accountModel.id,
    };
    webSocketService.sendMessageWebSocket(channel, event);
    if (accountModel.id.isNotEmptyAndNotNull &&
        accountModel.getAccountType! ==
            accountType.accountTypeValue(AccountTypeEnum.DRIVER)) {
      _initLocationService();
    }
    _listenWebsockets();
  }

  void _initLocationService() {
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 5));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    }

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        String currentTime = datesUtil.getCurrentTime(
            constants.AFRICA_DAKAR, constants.YYYY_MM_DD_HH_MM_SS);
        int datetime = datesUtil.convertDateTimeToMilliseconds(
            currentTime, constants.AFRICA_DAKAR, constants.YYYY_MM_DD_HH_MM_SS);

        var accountData = {
          '_id': accountModel.id,
          'accountId': accountModel.accountId,
          'accountType': accountModel.accountType,
          'phoneNumber': accountModel.phoneNumber,
          'status': accountModel.status,
        };
        var positionData = {
          'latitude': position.latitude,
          'longitude': position.longitude
        };
        var driverPositionData = {
          'datetime': datetime,
          'accountModel': accountData,
          'positionModel': positionData,
          'status': driverPositionStatus
              .driverPositionStatusValue(DriverPositionStatusEnum.AVAILABLE)
        };

        // Web Socket
        final event = {
          'action': constants.UPDATE_DRIVER_POSITION,
          'roomId': accountModel.id,
          'driverPosition': driverPositionData,
        };
        webSocketService.sendMessageWebSocket(channel, event);
      } else {
        _displayMessage(
            'Attention vous devez activer la géolocalisation pour pouvoir travailler !',
            Colors.red);
      }
    });
  }

  void _listenWebsockets() {
    channel.stream.listen(
      (message) {
        // Handle incoming WebSocket messages
        print('Received: $message');
      },
      onDone: () async {
        // Handle WebSocket disconnection
        print('WebSocket connection closed');
        final token = await SharedPreferencesUtil().getToken();
        if (token.isNotEmptyAndNotNull) {
          _keepWebSocketAlive(channel);
        }
      },
      onError: (error) async {
        // Handle WebSocket errors
        print('WebSocket error: $error');
        final token = await SharedPreferencesUtil().getToken();
        if (token.isNotEmptyAndNotNull) {
          _keepWebSocketAlive(channel);
        }
      },
    );
    _keepWebSocketAlive(channel);
  }

  Future<void> _keepWebSocketAlive(IOWebSocketChannel channel,
      {event = null}) async {
    heartbeatTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (event == null) {
        event = {'action': 'keepWebsocketsAlive', 'message': 'KWA'};
      }
      channel.sink.add(jsonEncode(event));
    });
  }

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting(constants.FR_FR, null);
  }

  void _logoutAccount(context) {
    sharedPreferencesUtil.setLocalDataByKey('token', '');
    positionStream?.cancel();
    heartbeatTimer?.cancel();
    // Web Socket
    final event = {
      'action': constants.LEAVE_ROOM,
      'roomId': accountModel.id,
    };
    webSocketService.sendMessageWebSocket(channel, event);
    webSocketService.closeWebSocket(channel);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    heartbeatTimer?.cancel();
    webSocketService.closeWebSocket(channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), backgroundColor: Colors.green),
      body: Container(
        child: _displayComponentDynamically(),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                accountModel.phoneNumber.toString(),
                style: optionStyle,
              ),
              accountEmail: Text(
                accountType.getAccountTypeValue(accountModel.accountType),
                style: optionStyle,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                //backgroundImage: AssetImage('assets/images/dw-default.png'),
              ),
              decoration: BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: Icon(Icons.car_repair),
              title: const Text('Course'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: const Text('Commandes'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: const Text('Compte'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () {
                _logoutAccount(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
