import 'dart:io';
import 'dart:convert';


Socket sock;
main() async {
//  var data = [
//    'GET /app/%3Ftransient%3D HTTP/1.1',
//    'Connection: Upgrade',
//    'upgrade: websocket',
//    'host: 192.168.188.10',
//    'Sec-WebSocket-Version: 13',
//    'Sec-WebSocket-Key: MTMtMTQ0OTM0Mzg2MTM4Ng==',
//    'Content-Type: application/json',
//    'cookie: X-Qlik-Session=e2b64cad-abf6-43f8-993d-a861ae657657; Path=/; HttpOnly; Secure',
//    'sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits',
//    '',
//    ''
//  ];
////
//  sock = await Socket.connect('192.168.188.10', 80);
////  socket = await Socket.connect('net.tutsplus.com', 80);
//  sock.listen(onMessage);
//  var message = data.join('\r\n');
//  sock.write(message);
//  return;

  var host = '192.168.188.10';
//  var pfx = new File('sample/.pfx').readAsBytesSync();
  SecurityContext clientContext = new SecurityContext()
    ..usePrivateKey('sample/client_key.pem');
  var client = new HttpClient();
  client.badCertificateCallback = (_,__,___)=>true;
//  var request = await client.getUrl(
//      Uri.parse("https://example.com/"));
//  var response = await request.close();
  var pfx = new File('sample/client.pfx').readAsBytesSync();

  var socket = await SecureSocket.connect('192.168.188.10',4243,onBadCertificate: (_) =>true);
  socket.listen(onMessage);
  var body = JSON
      .encode({"UserDirectory": 'SERV10',
    "UserId": 'vts',
    "Attributes": []});

    var data = [
    'POST /qps/ticket?xrfkey=abcdefghijklmnop HTTP/1.1.',
    'host: 192.168.188.10',
    'x-qlik-xrfkey: abcdefghijklmnop',
    'rejectUnauthorized: false',
    'Content-Type: application/json',
    'Content-Length: ${body.length}',
    '',
  ];
//
//  var message = data.join('\r\n');
//  socket.write(message);
//  print(message + '|');
//  socket.write(body);



//  var body = JSON
//      .encode({"UserDirectory": 'SERV10',
//    "UserId": 'vts',
//    "Attributes": []});
//  request.headers
//    ..add('x-qlik-xrfkey', 'abcdefghijklmnop')
//    ..add('rejectUnauthorized', false)
//    ..add('host', host)
////    ..add('pfx', pfx)
//    ..add('content-type', 'application/json');



}

onMessage(List event) {
  var message = UTF8.decode(event, allowMalformed: true);
  print(message);
  sock.close();
}
