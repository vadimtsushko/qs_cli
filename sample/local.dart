import 'dart:io';
import 'dart:convert';
import 'dart:async';


Socket socket;
WebSocket ws;
main() async {

    var data = [
    'GET /app/%3Ftransient%3D HTTP/1.1',
    'Connection: Upgrade',
    'Upgrade: websocket',
    'Host: localhost',
    'Sec-WebSocket-Version: 13',
    'Sec-WebSocket-Key: MTMtMTQ0OTM0Mzg2MTM4Ng==',
    'Content-Type: application/json',
    'sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits',
    '',
    ''
  ];

  socket = await Socket.connect('localhost', 4848);
//    socket.listen(onMessage);
  print(socket);
    var message = data.join('\r\n');
  socket.write(message);
  await new Future.delayed(new Duration(seconds: 1));
  ws = new WebSocket.fromUpgradedSocket(socket,serverSide: true);
  print(ws);
  ws.listen(onMessage);
  ws.add('{"1":2}');

}


onMessage(List event) {
  print('here');
  var message = UTF8.decode(event, allowMalformed: true);
  print(message);
}
