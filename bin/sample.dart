import "package:websockets/websockets.dart";
import "dart:async";
//import 'dart:io';
WebSocket ws;
main() async {
  //ws = await WebSocket.connect("ws://localhost:8001/");
  ws = await WebSocket.connect("ws://192.168.188.10/app/%3Ftransient%3D");
  await new Future.delayed(const Duration(seconds: 2), () => null);
  ws.listen(onMessage);
  var message = '''
  {
  "method": "OpenDoc",
  "handle": -1,
  "params": [
    "TestInterface"
  ],
  "id": 3,
  "jsonrpc": "2.0"
}
  ''';
  ws.add(message);
  await new Future.delayed(const Duration(seconds: 1), () => null);
  ws.close();
}
onMessage(var message) {
  print(message);
}
