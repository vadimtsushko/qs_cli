import "package:dart_qv/engine.dart";

const APP_ID = 'd6a397f1-5bb1-4495-8edd-4205bd16dc81';
const USER_ID = 'vts';
const SERVER_ID = 'SERV10';

main() async {
  var engine = new Engine();
  var global = await engine.init(SERVER_ID,SERVER_ID,USER_ID);
  var app = await global.openDoc(APP_ID);
  var measures = await app.getMeasures();
  for (var each in measures) {
    print(each);
  }
  engine.close();

}
