/**
 * @created 17/10/2023 - 10:00
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:aindia_auto_app/services/socket/websocket.service.dart';
import 'package:aindia_auto_app/utils/shared.preferences.util.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_socket_channel/io.dart';
import 'components/home/login.dart';
import 'dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await SharedPreferencesUtil().getToken();

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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    // Web Socket
    webSocketService.startWebSocket(channel);
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
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (_) => accountModel),
                    ],
                    child: MaterialApp(
                      title: 'Aindia Auto',
                      home: Dashboard(selectedIndex: 1),
                    ),
                  );
                } else {
                  return const Login();
                }
              } else {
                return const Login();
              }
            }
          }
        });
  }
}
