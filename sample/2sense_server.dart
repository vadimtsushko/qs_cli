library reader_tests;

import "package:dart_qv/engine.dart";
import 'package:inqlik_cli/src/qv_exp_reader.dart';

const APP_ID = '1a40f85c-9836-42d3-bf42-eee33b23eca4';
const USER_ID = 'vts';
//const APP_ID = '56c13c6f-b32b-4c8a-911b-c27cc622336d';
//const USER_ID = 'osk';

main() async {
  var reader = newReader()
    ..readFile(r'sample\exp_files\App.Variables.qlikview-vars');
  reader.checkSyntax();
  if (reader.errors.isNotEmpty) {
    reader.printStatus();
  }
  final variableReferencePattern =
      new RegExp(r'\$\(([\wА-Яа-яA-Za-z._0-9]*)[)(]');
  var variablesToImportIds = new Set<String>();
  int variableCounter = 0;
  int measureCounter = 0;
  var expressionMap = new Map<String, ExpressionData>();
  for (var entry in reader.entries) {
    if (entry.entryType == EntryType.EXPRESSION) {
      var data = entry.expression.getData();
      expressionMap[data.name] = data;
      variableCounter++;
      if (data.label != '' && data.comment != '') {
        measureCounter++;
      }
//      for (var m in variableReferencePattern
//          .allMatches(entry.expression.expandedDefinition)) {
//        variablesToImportIds.add(m.group(1));
//      }
      variablesToImportIds.add(entry.expression.name);

    }
  }
  print(
      'Variables: $variableCounter, referenced variables: ${variablesToImportIds
          .length}, measures: $measureCounter');

  var variablesToImport = new Map<String, VariableDef>();
  var notFoundSet = new Set<String>();
  for (var varId in variablesToImportIds) {
    var exprData = expressionMap[varId];
    if (exprData == null) {
      print('Referenced variable definition not found: $varId');
      notFoundSet.add(varId);
    } else {
      var vDef = new VariableDef(varId, exprData.definition, exprData.comment);
      variablesToImport[varId] = vDef;
    }
  }
  for (var varId in notFoundSet) {
    variablesToImportIds.remove(varId);
  }

  var engine = new Engine();
  var global = await engine.init(USER_ID);
  print(global);

  var app = await global.openDoc(APP_ID);

//  var measures = await app.getMeasures();
//  for (var each in measures) {
//    print('${each.id} ${each.title}');
//  }
//  engine.close();
//  return;

  print('******************** LOADING VARIABLES');

  var varsPresentInApp = await app.getVariables();
  var varsInApp = varsPresentInApp.map((varDef) => varDef.name).toSet();

  var varsToUpdate = variablesToImportIds.intersection(varsInApp);
  var varsToDelete = varsInApp.difference(variablesToImportIds);
  var varsToInsert = variablesToImportIds.difference(varsInApp);
//  for (var name in varsToUpdate) {
//    var varDef = varsPresentInApp.firstWhere((varDef)=>varDef.name == name);
//    if ()
//  }

  print(
      'To update: ${varsToUpdate.length}, To delete: ${varsToDelete.length} To insert: ${varsToInsert.length}');

//  print(varsToDelete);
//  print(varsToInsert);
//
//  var debug = expressionMap['ПоказательСУчетомНедель'];
//  return;

  for (var each in varsToInsert) {
    var vDef = variablesToImport[each];
    await app.createVariableEx(vDef);
  }
  for (var each in varsToDelete) {
    await app.destroyVariableByName(each);
  }
  for (var each in varsToUpdate) {
    await app.updateVariable(variablesToImport[each]);
  }

//  app.doSave();
  await app.saveObjects();

  print('******************** LOADING MEASURES');

  var measuresToImport = new Map<String, MeasureDef>();

//  print(expressionMap.values);
  for (var exprData in expressionMap.values) {
    if (exprData.label != '') {
      var measureId = 'MEASURE_' + exprData.name;
      var measureDefinition = '\$(${exprData.name})';
      measuresToImport[measureId] = new MeasureDef(
          measureId, measureDefinition, exprData.label,
          description: exprData.comment, tags: [exprData.name, 'Imported']);
    }
  }
  var measuresToImportIds = measuresToImport.keys.toSet();

//  print(measuresToImportIds);

  var measuresInApp = (await app.getMeasures()).toSet();
//  print(measuresInApp);
  var measuresToUpdate = measuresToImportIds.intersection(measuresInApp);
  var measuresToDelete = measuresInApp.difference(measuresToImportIds);
  var measuresToInsert = measuresToImportIds.difference(measuresToImportIds);

  print(
      'To update: ${measuresToUpdate.length}, To delete: ${measuresToDelete.length} To insert: ${measuresToInsert.length}');

  for (var id in measuresToUpdate) {
    var mDef = measuresToImport[id];
    await app.updateMeasure(mDef);
  }

  for (var id in measuresToInsert) {
    var mDef = measuresToImport[id];
    await app.createMeasure(mDef);
  }

  for (var id in measuresToDelete) {
    await app.destroyMeasure(id);
  }

//  app.doSave();
  await app.saveObjects();

  await engine.close();
}
