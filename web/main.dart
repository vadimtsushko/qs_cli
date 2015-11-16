// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';

WebSocket ws;
_print(obj) {
  StringBuffer sb = new StringBuffer();
  var out = querySelector('#output');
  sb.write(out.text);
  sb.writeln(obj);
  out.text = sb.toString();
}
void main() {
  querySelector('#btn').onClick.listen(test);
}

void test(ev) {
    initWebSocket();
}


void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;

  print("Connecting to websocket");
  //ws = new WebSocket('ws://localhost:4848/app/%3Ftransient%3D');
  ws = new WebSocket('ws:/localhost:8001/');

  void scheduleReconnect() {
    if (!reconnectScheduled) {
      new Timer(
          new Duration(milliseconds: 1000 * retrySeconds),
              () => initWebSocket(retrySeconds * 2));
    }
    reconnectScheduled = true;
  }

  ws.onOpen.listen((e) {
  _print('Connected');
    ws.send('Hello from Dart!');
  });

  ws.onClose.listen((e) {
    _print('Websocket closed, retrying in ' +
    '$retrySeconds seconds');
    scheduleReconnect();
  });

  ws.onError.listen((e) {
    _print("Error connecting to ws");
    scheduleReconnect();
  });

  ws.onMessage.listen((MessageEvent e) {
    _print('Received message: ${e.data}');
  });
}