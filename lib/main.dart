import 'package:aindia_auto_app/services/socket/websocket.service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_socket_channel/io.dart';

import 'components/home/login.dart';

/*
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final String tokenString = preferences.getString('token') ?? '';

  runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('fr'),
    ],
    home: MyApp(token: tokenString),
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
  /*bool _isLoading = false;

  loader() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }*/

  // Web Socket
  WebSocketService webSocketService = WebSocketService();
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  Future<bool> checkTokenStatus(String token) async {
    if (token == '') {
      return false;
    } else {
      return !JwtDecoder.isExpired(token);
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
    return Container(child: Login(),);
    /*return FutureBuilder<bool>(
      future: checkTokenStatus(widget.token),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final bool isTokenValid = snapshot.data!;
          if (isTokenValid) {
            var decodedToken = JwtDecoder.decode(widget.token);
            final userModel = UserModel(
              decodedToken['_id'],
              company: decodedToken['company'],
              email: decodedToken['email'],
              status: decodedToken['status'],
              token: widget.token,
              role: decodedToken['role'],
              userId: decodedToken['userId'],
            );
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<UserModel>.value(value: userModel),
                ChangeNotifierProvider<UserIdentityModel>.value(
                    value: userIdentity),
              ],
              child: MaterialApp(
                title: 'Door War',
                home: EmployeeDashboardPage(selectedIndex: 1),
              ),
            );
          } else {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<UserModel>.value(
                    value: UserModel(
                      '',
                      company: '',
                      email: '',
                      status: 0,
                      token: '',
                      role: 0,
                      userId: '',
                    )),
                ChangeNotifierProvider<UserIdentityModel>.value(
                    value: userIdentity),
              ],
              child: MaterialApp(
                title: 'Door War',
                home: const UserLoginAccount(),
              ),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );*/
  }
}
