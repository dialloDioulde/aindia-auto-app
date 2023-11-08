/**
 * @created 19/10/2023 - 22:59
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:web_socket_channel/io.dart';

import '../config/config.service.dart';

class WebSocketService {
  String webSocketApiUrl = ConfigService().webSocketApiUrl;

  IOWebSocketChannel setupWebSocket() {
    return IOWebSocketChannel.connect(webSocketApiUrl);
  }

  void startWebSocket(IOWebSocketChannel channel) {
    channel.stream.listen((message) {});
  }

  void sendMessageWebSocket(IOWebSocketChannel channel, event) {
    channel.sink.add(jsonEncode(event));
  }

  void closeWebSocket(IOWebSocketChannel channel) {
    channel.sink.close();
  }
}