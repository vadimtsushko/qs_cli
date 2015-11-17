import "package:dart_qv/engine.dart";
import "dart:async";
//import 'dart:io';
main() async {
  var engine = new Engine();
  var res = await engine.init();
  print(res);
  var reply = await engine.query(-1, 'OpenDoc', ['TestInterface']);
  print(reply);
  engine.close();
}
