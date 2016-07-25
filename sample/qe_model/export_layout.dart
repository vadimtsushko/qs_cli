import "package:dart_qv/engine.dart";
import 'package:qe_model/models.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:matcher/matcher.dart';
import 'dart:async';

const APP_ID = '46f36618-e11d-41db-b917-6595d66d87eb';
const USER_ID = 'vts';
const SERVER_ID = 'SERV10';

main() async {
  var engine = new Engine();
  var global = await engine.init('192.168.188.10', SERVER_ID, USER_ID);
//  var docs = await global.getDocList();
//  for (var each in docs) {
//    print('${each.qDocName} ${each.qTitle} ${each.qReadOnly} ${each.qLastReloadTime} docId: ${each.qDocId}');
//  }
  var dataPath = '.data/$APP_ID';
  var dir = new Directory(dataPath);
  if (dir.existsSync()) {
    await dir.delete(recursive: true);
  }
  await dir.create();
  var app = await global.openDoc(APP_ID);
  var sheetList = await app.getSheets();
  for (var each in sheetList) {
    var sheet = await app.getObject(each);
    var result = await sheet.getFullPropertyTree();
    var entry = result['result']['qPropEntry'];
    String name = entry['qProperty']['qMetaDef']['title'];
    var json = new JsonEncoder.withIndent('    ').convert(entry);
    var file = new File('$dataPath/$name.layout.json');
    await file.writeAsString(json, flush: true);
  }
  await engine.close();
}

