/**
 * @created 27/05/2023 - 20:00
 * @project door_war_app
 * @author mamadoudiallo
 */

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/auth.util.dart';
import '../utils/shared-preferences.util.dart';


class DashboardPage extends StatefulWidget {
  late int selectedIndex;

  DashboardPage({required this.selectedIndex, Key? key})
      : super(key: key);

  @override
  State<DashboardPage> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<DashboardPage> {
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();
  AuthUtil authUtil = AuthUtil();
  late String userId = '';
  late String email;
  late List userActivities = [];
  String _title = 'Tableau de bord';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      if (widget.selectedIndex == 0) {
        _title = 'Tableau de bord';
      }
      if (widget.selectedIndex == 1) {
        _title = 'Activités';
      }
      if (widget.selectedIndex == 2) {
        _title = 'Profile';
      }
    });
  }

  initializeData() async {
    String token = await authUtil.getToken();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    email = jwtDecodedToken['email'];
    userId = jwtDecodedToken['_id'];
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
                },
              )
            ],
          )
        ),
        backgroundColor: HexColor("#223366"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: null,
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
            icon: Icon(Icons.task),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_identity,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
