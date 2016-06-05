import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:dart_qv/engine.dart";

const APP_ID = '1a40f85c-9836-42d3-bf42-eee33b23eca4';
const USER_ID = 'vts';

main() async {
//  var url = "https://192.168.188.10:4243/qps/ticket?xrfkey=abcdefghijklmnop";
//  var body = JSON.encode({"UserDirectory": 'SERV10', "UserId": 'vts'});
//  var headers = {
//    'x-qlik-xrfkey': 'abcdefghijklmnop',
//    'content-type': 'application/json'
//  };
//  SecurityContext clientContext = new SecurityContext();
//  clientContext.setClientAuthorities('sample/client.pem');
//  clientContext.setTrustedCertificates('sample/root.pem');
//  //clientContext.setTrustedCertificates('sample/client.pfx');
////  clientContext.usePrivateKey('sample/client_key.pem');
//
//  var _client = new HttpClient(context: clientContext);
////  _client.badCertificateCallback = (_,__,___)=>true;;
//  http.IOClient client = new http.IOClient(_client);
//
//  var response = await client.post(url, body: body, headers: headers);
//  print(response.body);
//  client.close();
  var ticketInfo = await Process.run('SenseTicket', ['192.168.188.10','SERV10','vts']);
  print(ticketInfo.stdout);
  ticketInfo = JSON.decode(ticketInfo.stdout);
  var ticket = ticketInfo['Ticket'];
  print(ticketInfo);
//  var client = new HttpClient();
//  client.get('192.168.188.10',80,'hub/?qlikTicket=' + ticket);
   var response = await http.get('http://192.168.188.10/hub/?qlikTicket=' + ticket);
   var cookie = response.headers['set-cookie'];
   print(cookie);

  var engine = new Engine();
  await engine.initWithCookie('ws://192.168.188.10/app/%3Ftransient%3D',cookie);
  var global = new Global(engine);
  print(global);
  var app = await global.openDoc(APP_ID);
  print('here');
  print(app);
  var measures = await app.getMeasures();
  for (var each in measures) {
    print(each);
  }
  engine.close();

}
