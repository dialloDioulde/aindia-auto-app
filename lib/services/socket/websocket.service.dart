/**
 * @created 19/10/2023 - 22:59
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:web_socket_channel/io.dart';

class WebSocketService {

  IOWebSocketChannel setupWebSocket() {
    return IOWebSocketChannel.connect('ws://10.0.2.2:3000');
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