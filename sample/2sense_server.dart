library reader_tests;

import "package:dart_qv/engine.dart";
import 'package:inqlik_cli/src/qv_exp_reader.dart';

const APP_ID = 'c16cc3aa-a04d-45e4-ac05-8d85996ea145';
main() async {
  var reader = newReader()
    ..readFile(r'sample\exp_files\App.Variables.qlikview-vars');
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
      for (var m in variableReferencePattern
          .allMatches(entry.expression.expandedDefinition)) {
        variablesToImportIds.add(m.group(1));
      }
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
      var vDef = new VariableDef(
          varId, exprData.definition, exprData.comment);
      variablesToImport[varId] = vDef;
    }
  }
  for (var varId in notFoundSet) {
    variablesToImportIds.remove(varId);
  }

  var engine = new Engine();
  var global = await engine.init('vts');
  print(global);

  var app = await global.openDoc(APP_ID);

  var varsInApp = await app.getVariablesSet();


  var varsToUpdate = variablesToImportIds.intersection(varsInApp);
  var varsToDelete = varsInApp.difference(variablesToImportIds);
  var varsToInsert = variablesToImportIds.difference(varsInApp);
  print('To update: ${varsToUpdate.length}, To delete: ${varsToDelete.length} To insert: ${varsToInsert.length}');
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
//
//  print(await app.saveObjects());
  app.doSave();
  app.saveObjects();



  print('******************** LOADING MEASURES');
  var measuresToImport = new Map<String, MeasureDef>();

  for (var exprData in expressionMap.values) {
    if(exprData.label != '') {
      var measureId = 'MEASURE_' + exprData.name;
      measuresToImport[measureId] = new MeasureDef(measureId,exprData.definition,exprData.label, description: exprData.comment);
    }
  }
  print('Measures to load: ${measuresToImport.length}');
  for (var mDef in measuresToImport.values) {
    await app.createOrUpdateMeasure(mDef);
  }





  engine.close();




}
