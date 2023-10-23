/**
 * @created 17/10/2023 - 17:25
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/components/home/login.dart';
import 'package:aindia_auto_app/components/map/map.component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import '../models/account.model.dart';
import '../services/socket/websocket.service.dart';
import '../utils/shared-preferences.util.dart';

class Dashboard extends StatefulWidget {
  late int selectedIndex;

  Dashboard({required this.selectedIndex, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<Dashboard> {
  AccountModel accountModel = AccountModel('');
  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  late String userId = '';
  late String email;
  late List userActivities = [];
  String _title = 'Course';

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      if (widget.selectedIndex == 0) {
        _title = 'Tableau de bord';
      }
      if (widget.selectedIndex == 1) {
        _title = 'Course';
      }
      if (widget.selectedIndex == 2) {
        _title = 'Compte';
      }
    });
  }

  void _logoutAccount() {
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

  _displayComponentDynamically() {
    if (widget.selectedIndex == 0) {}
    if (widget.selectedIndex == 1) {
      return MapComponent();
    }
    if (widget.selectedIndex == 2) {}
  }

  initializeData() async {
    accountModel = Provider.of<AccountModel>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_title),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                _logoutAccount();
              },
            )
          ],
        )),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _displayComponentDynamically(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
            ),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_identity,
            ),
            label: 'Compte',
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
