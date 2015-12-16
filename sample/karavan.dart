import "package:dart_qv/engine.dart";

final counter = 2;
final minId = 29;
final maxId = 30;
main() async {
//  final testAppName = 'b73c3eee-4e6c-458a-b8eb-3ee94aa07c88';
  final testAppName = '233364b9-b0ae-465d-80de-e6f7101a55cb';
  var engine = new Engine();
  var global = await engine.init();
  print(global);

  var app = await global.openDoc(testAppName);

  var varsInApp = await app.getVariablesSet();
  print(varsInApp);
  var variablesToImport = new Map<String, VariableDef>();
  var variablesToImportIds = new Set<String>();
  for (int n = minId; n <= maxId; n++) {
    var id = n.toString().padLeft(4, '0');
    var vDef = new VariableDef(
        'Variable' + id, 'Sum(Expression2) * $n + $n', 'Variable $id');
    variablesToImport['Variable' + id] = vDef;
    variablesToImportIds.add('Variable' + id);
//    print(await app.createVariableEx(vDef));
  }
  var varsToUpdate = variablesToImportIds.intersection(varsInApp);
  var varsToDelete = varsInApp.difference(variablesToImportIds);
  var varsToInsert = variablesToImportIds.difference(varsInApp);
  print('To update: $varsToUpdate');
  print('To delete: $varsToDelete');
  print('To insert: $varsToInsert');
  for (var each in varsToInsert) {
    var vDef = variablesToImport[each];
    print(await app.createVariableEx(vDef));
  }
  for (var each in varsToDelete) {
   print(await app.destroyVariableByName(each));
  }
  for (var each in varsToUpdate) {
    print(await app.updateVariable(variablesToImport[each]));
  }
//
//  print(await app.saveObjects());
  app.doSave();
  app.saveObjects();
  engine.close();
}
