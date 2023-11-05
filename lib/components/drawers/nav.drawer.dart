/**
 * @created 29/10/2023 - 16:10
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:async';

import 'package:aindia_auto_app/components/orders/list.order.dart';
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
import '../../models/driver-position/driver-position.model.dart';
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
import '../home/login.dart';
import '../map/map.component.dart';

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
        _title = "Taxi";
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
        return MapComponent();
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
    // Web Socket
    final event = {
      'action': "createRoom",
      'roomId': accountModel.id,
    };
    webSocketService.sendMessageWebSocket(channel, event);
    if (accountModel.id.isNotEmptyAndNotNull &&
        accountModel.getAccountType! ==
            accountType.accountTypeValue(AccountTypeEnum.DRIVER)) {
      _initLocationService();
    }
  }

  void _initLocationService() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        String currentTime =
            datesUtil.getCurrentTime('Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');
        int datetime = datesUtil.convertDateTimeToMilliseconds(
            currentTime, 'Africa/Dakar', 'yyyy-MM-dd HH:mm:ss');
        positionModel = MapPositionModel(position.latitude, position.longitude);
        DriverPositionModel driverPositionModel = DriverPositionModel(
            '',
            datetime,
            accountModel,
            positionModel!,
            driverPositionStatus
                .driverPositionStatusValue(DriverPositionStatusEnum.AVAILABLE));

        // Web Socket
        final event = {
          'action': "createRoom",
          'roomId': accountModel.id,
          'driverPosition': driverPositionModel.toJson(),
        };
        webSocketService.sendMessageWebSocket(channel, event);
      } else {
        _displayMessage(
            'Attention vous devez activer la géolocalisation pour pouvoir travailler !',
            Colors.red);
      }
    });
  }

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting("fr_FR", null);
  }

  void _logoutAccount(context) {
    sharedPreferencesUtil.setLocalDataByKey('token', '');
    positionStream?.cancel();
    // Web Socket
    final event = {
      'action': "leaveRoom",
      'roomId': accountModel.id,
    };
    webSocketService.sendMessageWebSocket(channel, event);
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
    super.dispose();
    positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), backgroundColor: Colors.green),
      body: Container(
        child: _displayComponentDynamically(),
      ),
      /*body: Center(
        child: _displayComponentDynamically(),
      ),*/
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
              title: const Text('Taxi'),
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
