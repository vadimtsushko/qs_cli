import 'dart:io';
import 'dart:convert';

main() async {
  var host = '192.168.188.10';
  var pfx = new File('sample/client.pfx').readAsBytesSync();
  SecurityContext clientContext = new SecurityContext()
    ..setTrustedCertificates(file: 'sample/qs.pem');
  var client = new HttpClient();
  client.badCertificateCallback = (_,__,___)=>true;
//  var request = await client.getUrl(
//      Uri.parse("https://example.com/"));
//  var response = await request.close();
  var request = await client.openUrl(
      'POST', Uri.parse('https://192.168.188.10:4243/qps/ticket?xrfkey=abcdefghijklmnop'));
  var body = JSON
      .encode({"UserDirectory": 'SERV10',
    "UserId": 'vts',
    'pfx': pfx,
    "Attributes": []});
  request.headers
    ..add('x-qlik-xrfkey', 'abcdefghijklmnop')
    ..add('rejectUnauthorized', false)
    ..add('host', host)
//    ..add('pfx', pfx)
    ..add('content-type', 'application/json');

  request.write(body);
  var response = await request.close();
  print(response.headers);
  print(response.statusCode);
  print(response.reasonPhrase);

  response.listen((contents) {
              print(contents);
            });

}
