/**
 * @created 17/10/2023 - 10:00
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:aindia_auto_app/services/config/config.service.dart';
import 'package:aindia_auto_app/services/socket/websocket.service.dart';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_socket_channel/io.dart';
import 'components/drawers/nav.drawer.dart';
import 'components/home/login.dart';
import 'models/identity/identity.model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await SharedPreferencesUtil().getToken();

  // Files env configuration
  await ConfigService().loadConfig(envFileName: '.env.dev');

  runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('fr'),
    ],
    home: MyApp(token: token),
  ));
}

class MyApp extends StatefulWidget {
  final String token;

  const MyApp({
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AccountModel accountModel = AccountModel('');

  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  Future<bool> checkTokenStatus(String token) async {
    if (token == '') {
      return false;
    } else {
      return true;
    }
  }

  _initializeData() async {
    // Web Socket
    webSocketService.startWebSocket(channel);
    initializeDateFormatting();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    webSocketService.closeWebSocket(channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkTokenStatus(widget.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("Chargement...");
          } else {
            if (snapshot.hasError) {
              return Text([snapshot.error.toString()] as String);
            } else {
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  var decodedToken = JwtDecoder.decode(widget.token);
                  final accountModel = AccountModel(
                    decodedToken['_id'],
                    accountId: decodedToken['accountId'],
                    accountType: decodedToken['accountType'],
                    phoneNumber: decodedToken['phoneNumber'],
                    status: decodedToken['status'],
                    token: widget.token,
                  );
                  IdentityModel identityModel =
                      IdentityModel('', accountModel, '', '');
                  if (decodedToken['identity'] != null) {
                    identityModel = IdentityModel(
                        decodedToken['identity']['_id'],
                        AccountModel(''),
                        decodedToken['identity']['firstname'],
                        decodedToken['identity']['lastname']);
                  }
                  accountModel.identity = identityModel;
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<AccountModel>(
                          create: (context) => accountModel),
                    ],
                    child: MaterialApp(
                      title: 'Aindia Auto',
                      home: NavDrawer(),
                    ),
                  );
                } else {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<AccountModel>.value(
                          value: accountModel),
                    ],
                    child: MaterialApp(
                      title: 'Connexion',
                      home: const Login(),
                    ),
                  );
                }
              } else {
                return const Login();
              }
            }
          }
        });
  }
}
