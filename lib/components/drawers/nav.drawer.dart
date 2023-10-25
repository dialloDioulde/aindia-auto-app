import 'package:aindia_auto_app/components/orders/list.order.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import '../../models/account.model.dart';
import '../../services/socket/websocket.service.dart';
import '../../utils/shared-preferences.util.dart';
import '../home/login.dart';
import '../map/map.component.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  AccountModel accountModel = AccountModel('');

  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  String _title = 'Taxi';
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

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
      return MapComponent();
    }
    if (_selectedIndex == 1) {
      return ListOrder();
    }
    if (_selectedIndex == 2) {
      //return AccountComponent();
    }
  }

  _initializeData() async {
    var data = await sharedPreferencesUtil.getAccountDataFromToken();
    setState(() {
      accountModel = data;
    });
  }

  void _logoutAccount(context) {
    sharedPreferencesUtil.setLocalDataByKey('token', '');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title), backgroundColor: Colors.green),
      body: Center(
        child: _displayComponentDynamically(),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(accountModel.phoneNumber.toString()),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                //backgroundImage: AssetImage('assets/images/dw-default.png'),
              ),
              decoration: BoxDecoration(color: Colors.green),
            ),
            ListTile(
              title: const Text('Taxi'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Mes Commandes'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
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
