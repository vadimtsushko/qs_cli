import 'dart:io';
WebSocket ws;
main() async {

  var c1 = 'X-Qlik-Session=e2b64cad-abf6-43f8-993d-a861ae657657; Path=/; HttpOnly; Secure';
  var headers = {
    "Content-Type": "application/json",
"Cookie": c1
};

ws = await WebSocket.connect('ws://192.168.188.10:80/app/%3Ftransient%3D', headers: headers, compression: CompressionOptions.OFF);
print(ws);
}


