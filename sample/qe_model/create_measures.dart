import "package:dart_qv/engine.dart";
import 'package:qe_model/models.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:matcher/matcher.dart';
import 'dart:async';

const APP_ID = '571ee2e9-c871-4e27-8e30-6df20730d84b';
const USER_ID = 'osk';
const SERVER_ID = 'SERV10';

main() async {
  var exprHeader = [
    'ExpressionName',
    'Label',
    'Comment',
    'Description',
    'Section',
    'Definition',
    'Width'
  ];

  var exprList = await getCsvData(
      exprHeader, r'c:\Projects\infovizion\web\conf\App.Variables.table.csv');

//  var input = JSON.decode(
//      await new File(r'c:\Projects\infovizion\web\conf\dimensions.json')
//          .readAsString());
  var engine = new Engine();
  var global = await engine.init(SERVER_ID, SERVER_ID, USER_ID);
  print(global);
  var app = await global.openDoc(APP_ID);
  print(app);
  var measures = await app.getMeasures();
  for (var each in measures) {
    print('Destroying measure $each');
    await app.destroyMeasure(each);
  }

  for (var each in exprList.sublist(1)) {
    var exp = new QsMeasure.from(each);
    var measure = measureDef(exp);
    await app.createMeasure(measure);
    print(exp);
  }

  await app.saveObjects();

  await engine.close();
}

NxGenericMeasureProperties measureDef(QsMeasure input) {
  var id = 'Measure_' + input.id;
  return new NxGenericMeasureProperties()
    ..qInfo = (new NxInfo()
      ..qId = id
      ..qType = 'measure')
    ..qMeasure = (new NxLibraryMeasureDef()
      ..qDef = input.expression
      ..qLabel = input.label ?? input.id)
    ..qMetaDef = (new NxMeta()
      ..title = input.id
      ..description = input.comment);
}

Future<List<List>> getCsvData(List<String> testHeader, String fileName) async {
  Description desc = new StringDescription();
  var csvContent = await new File(fileName).readAsString();
  var lines = csvContent.split('\r\n');

  var decoder = new CsvCodec().decoder;

  var header = decoder.convert(lines.first).first;
  var matcher = orderedEquals(testHeader);
  Map state = {};

  if (!matcher.matches(header, state)) {
    Description desc = new StringDescription();
    matcher.describeMismatch(header, desc, state, true);

    throw new Exception('''
      Actual header row do not match expected values in file ${fileName}

      $desc
      ''');
  }
  //var csvData = lines.map((line) => decoder.convert(line).first).toList();
  var csvData = [];
  for (String line in lines) {
    if (line.trim() != '') {
      csvData.add(decoder.convert(line).first);
    }
  }
  return csvData;
}

class QsMeasure {
  String id;
  String label;
  String expression;
  String comment;
  int width;
  QsMeasure.from(List lst) {
    this.id = lst[0].toString();
    this.label = lst[1].toString();
    this.comment = lst[2].toString();
    this.expression = lst[5].toString();
    this.width = int.parse(lst[6].toString(), onError: (_) => null);
  }

  @override
  String toString() {
    return 'QsMeasure{id: $id, label: $label, expression: $expression, width: $width}';
  }
}
