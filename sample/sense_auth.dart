import "package:dart_qv/engine.dart";

const APP_ID = '1a40f85c-9836-42d3-bf42-eee33b23eca4';
const USER_ID = 'vts';

main() async {
  var engine = new Engine();
  var global = await engine.init('192.168.188.10','SERV10','vts');
  var app = await global.openDoc(APP_ID);
  var measures = await app.getMeasures();
  for (var each in measures) {
    print(each);
  }
  engine.close();

}
