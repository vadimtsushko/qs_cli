library reader_tests;

import "package:dart_qv/engine.dart";
import 'package:inqlik_cli/src/qv_exp_reader.dart';

const APP_ID = '1a40f85c-9836-42d3-bf42-eee33b23eca4';
const USER_ID = 'vts';
//const APP_ID = '56c13c6f-b32b-4c8a-911b-c27cc622336d';
//const USER_ID = 'osk';

main() async {
  var engine = new Engine();
  var global = await engine.init(USER_ID);
  print(global);

  var app = await global.openDoc(APP_ID);

  var measures = await app.getMeasures();
  for (var each in measures) {
    print(each);
  }
  engine.close();

}
