import "package:websockets/websockets.dart";
WebSocket ws;
main() async {
  ws = await WebSocket.connect("ws://localhost:8001/");
//  ws = await WebSocket.connect("ws://localhost:4848/app/TestInterface");
  ws.listen(onMessage);
  ws.add("test from console");
}
onMessage(var message) {
  print(message);
  ws.close();
}
