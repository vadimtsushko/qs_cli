library connection;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:quiver_log/web.dart';

Logger getLogger(String loggerName) {
  Logger _logger = new Logger(loggerName);
  Appender _logAppender = new WebAppender.webConsole(BASIC_LOG_FORMATTER);
  Logger.root.level = Level.ALL;
  _logAppender.attachLogger(_logger);
  return _logger;
}

class Connection {
  WebSocket webSocket;
  Logger _logger = getLogger('Connection');
  String uri = 'ws://localhost:4848/app/%3Ftransient%3D';
  bool isConnected = false;
  open() async {
    return setupWebSocket();
  }
  Future<bool> setupWebSocket() async {
    Completer<bool> completer;
    Uri _u = Uri.parse(uri);
    print(_u);
    webSocket = new WebSocket(uri);
    isConnected = true;
    webSocket.onOpen.listen((event) {
      isConnected = true;
      completer.complete(true);
    });

  }


}
