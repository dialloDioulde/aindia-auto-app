/**
 * @created 20/10/2023 - 16:10
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/account.model.dart';
import 'package:aindia_auto_app/services/config/config.service.dart';
import 'package:aindia_auto_app/utils/constants.dart';
import 'package:aindia_auto_app/utils/shared-preferences.util.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'components/drawers/nav.drawer.dart';
import 'components/account/login.dart';
import 'models/identity/identity.model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await SharedPreferencesUtil().getToken();
  // Files env configuration
  await ConfigService().loadConfig(envFileName: '.env.dev');
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var accountModel = AccountModel('');
  if (token != '') {
    var decodedToken = JwtDecoder.decode(token);
    accountModel = AccountModel(
      decodedToken['_id'],
      accountId: decodedToken['accountId'],
      accountType: decodedToken['accountType'],
      phoneNumber: decodedToken['phoneNumber'],
      status: decodedToken['status'],
      token: token,
    );
    IdentityModel identityModel = IdentityModel('', accountModel, '', '');
    if (decodedToken['identity'] != null) {
      identityModel = IdentityModel(
          decodedToken['identity']['_id'],
          AccountModel(''),
          decodedToken['identity']['firstname'],
          decodedToken['identity']['lastname']);
    }
    accountModel.identity = identityModel;
  }

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
  Constants constants = Constants();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => accountModel),
      ],
      child: MaterialApp(
        initialRoute: widget.token.isNotEmptyAndNotNull ? '/navDrawer' : '/',
        routes: {
          '/': widget.token.isNotEmptyAndNotNull
              ? (context) => NavDrawer()
              : (context) => Login(),
          '/navDrawer': (context) => NavDrawer(),
        },
      ),
    );
  }
}
