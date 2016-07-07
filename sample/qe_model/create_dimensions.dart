import "package:dart_qv/engine.dart";
import 'package:qe_model/models.dart';
import 'dart:io';
import 'dart:convert';

const APP_ID = 'd6a397f1-5bb1-4495-8edd-4205bd16dc81';
const USER_ID = 'vts';
const SERVER_ID = 'SERV10';

main() async {
  try {

  var input = JSON.decode(
      await new File(r'c:\Projects\infovizion\web\conf\dimensions.json')
          .readAsString());
  var engine = new Engine();
  var global = await engine.init(SERVER_ID, SERVER_ID, USER_ID);
  var app = await global.openDoc(APP_ID);

  var dims = await app.getDimensions();
  for (var each in dims) {
    var id = each['id'].toString().trim();
//    if (id == 'mqjXKK') {
//      print('Skip dimension $each');
//    } else {
//      print('Destroying dimension $each');
//      await app.destroyDimension(each['id']);
//    }
    if (id.startsWith('Dimension_')) {
      print('Destroying dimension $each');
      await app.destroyDimension(each['id']);
    } else {
      print('Skip dimension $each');
    }
  }
  var contentMap = <String,NxGenericDimensionProperties>{};
  for (var each in input) {
    var dimension = dimensionDef(each, contentMap);
    await app.createDimension(dimension);
  }
  await app.doSave();
  await app.saveObjects();

  await engine.close();
  } catch(e) {
    print(e);
  }

}

NxGenericDimensionProperties dimensionDef(Map input, Map<String, NxGenericDimensionProperties> dimensionMap) {
  String title = input['title'] ?? input['field'];
  if (title == null) {
    throw new Exception('Не заполнен title, field: $input');
  }
  var fieldDefs = [];
  var fieldLabels = [];
  if (input['field'] == null) {
    if (input['fields'] == null) {
      throw new Exception('Не заполнен fields, field: $input');
    }
    fieldDefs.addAll(input['fields']);
    for (var each in fieldDefs) {
      var dim = dimensionMap[each];
      if (dim == null) {
        fieldLabels.add(each);
      } else {
        fieldLabels.add(dim.qDim.qFieldLabels.first);
      }
    }
  } else {
    fieldDefs.add(input['field']);
    fieldLabels.add(title);
  }
  var id = 'Dimension_' + title.replaceAll(' ', '_');
  return new NxGenericDimensionProperties()
    ..qInfo = (new NxInfo()
      ..qId = id
      ..qType = 'dimension')
    ..qDim = (new NxLibraryDimensionDef()
      ..qGrouping = fieldDefs.length > 1 ? 'H' : 'N'
      ..qFieldDefs = fieldDefs
      ..qFieldLabels = fieldLabels)
    ..qMetaDef = (new NxMeta()..title = title);
}
