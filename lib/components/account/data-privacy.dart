/**
 * @created 14/11/2023 - 19:54
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/components/account/login.dart';
import 'package:aindia_auto_app/services/account.service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web_socket_channel/io.dart';
import '../../models/account-type.enum.dart';
import '../../models/account.model.dart';
import '../../services/socket/websocket.service.dart';
import '../../utils/permissions/permission.handler.dart';
import '../../utils/shared-preferences.util.dart';
import '../drawers/nav.drawer.dart';
import '../identity/identity.component.dart';

class DataPrivacy extends StatelessWidget {
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  DataPrivacy({Key? key}) : super(key: key);

  static const String _title = "Conditions d'utilisation";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: const Text(_title),
              backgroundColor: Colors.green),
          body: MyStatefulWidget(channel: channel),
          backgroundColor: Colors.white),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  MyStatefulWidget({channel, Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  AccountModel accountModel = AccountModel('');
  AccountType accountType = AccountType();

  AccountService accountService = AccountService();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  Future<void> _initializeData() async {
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
  }

  // Permissions handle
  Future<void> _requestPermissions() async {
    PermissionHandler permissionHandler = PermissionHandler();
    if (accountModel.id.isNotEmptyAndNotNull &&
        accountModel.getAccountType! ==
            accountType.accountTypeValue(AccountTypeEnum.DRIVER)) {
      final permissions = [
        Permission.location,
        Permission.notification,
        Permission.camera,
      ];
      final resultBool =
          await permissionHandler.requestPermissions(permissions);
      if (resultBool) {
        if (accountModel.identity?.id == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      IdentityComponent(channel: widget.channel)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NavDrawer(channel: widget.channel)));
        }
      } else {
        _logoutAccount();
      }
      //
    } else {
      final permissions = [
        Permission.location,
        Permission.notification,
      ];
      final resultBool =
          await permissionHandler.requestPermissions(permissions);
      if (resultBool) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NavDrawer(channel: widget.channel)));
      } else {
        _logoutAccount();
      }
    }
  }

  void _logoutAccount() {
    sharedPreferencesUtil.setLocalDataByKey('token', '');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
    return SingleChildScrollView(
        child: Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text(
                          "Nos Conditions d'Utilisations",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        SizedBox(height: 12),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                            child: Text(
                          "Le bon fonctionnement des services de l'application AINDIA AUTO, "
                          "le respect de vos données personnelles, l'obligation de se conformer à la loi régissant la protection des données personnelle, "
                          "nous oblige de vous demander les autorisations nécessaires.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                            child: Text(
                          "Vous pouvez accepter ou refuser, cependant si vous refusez vous serez automatiquement déconnecté de notre application "
                          "car ses autorisations sont nécessaires au bon fonctionnement de notre application.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                            child: Text(
                          "Vos données personnelles ne seront jamais vendues ou données à qui que ce soit "
                          "et vous aurez toujours la possibilité de demander une modification ou une suppression pure et simple de votre compte.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                            child: Text(
                          "Merci de cliquer sur le bounton ci-dessous pour gérer les permissions, merci pour la confiance.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          child: Text(
                            "Gérer les permissions",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            _requestPermissions();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ))));
  }
}
