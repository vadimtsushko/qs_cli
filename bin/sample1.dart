import "package:dart_qv/engine.dart";
import "dart:async";

//import 'dart:io';
main() async {
  var engine = new Engine();
  var global = await engine.init();
  print(global);

  var app = await global.openDoc('TestInterface');
  print(app);
  var toInsert = new Measure('qweqwq','Sum(Expression2)', 'Тест меры2', 'Новый тест меры');
  var reply = await app.createMeasure(toInsert);
  print(reply);
  reply = await app.saveObjects();
  print(reply);
//  int appHandle = reply['result']['qReturn']['qHandle'];
//  var params = [
//    {
//      "qInfo": {"qId": "VB01", "qType": "Variable"},
//      "qName": "Variable01",
//      "qComment": "My first variable",
//      "qDefinition": "=Count(Expression2)"
//    }
//  ];

//  var params = [
//    """
//    TRACE script set from file: E:\\GIT\\engine-sense-fork\\prod\\data\\Engine\\test\\qlikviewTests\\ProtocolTester4Net\\Resources\\\\CustomScript\\VariableScript_DOC.txt;
//    Let vSales  = '=Sum(Sales)' ;
//    Let vSales2  = '=Avg(Sales)' ;
//    """
//  ];
//
//  reply = await engine.query(appHandle, 'SetScript', params);
//  print(reply);
//
//  reply = await engine.query(appHandle, 'DoReload', []);
//  print(reply);

  engine.close();
}
