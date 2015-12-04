import "package:dart_qv/engine.dart";

final counter = 1500;
main() async {
  final testAppName = 'VariablesSample$counter';
  var engine = new Engine();
  var global = await engine.init();
  print(global);

  var res = await global.deleteApp(testAppName);
  print(res);

  var loadScript = '''
  Characters:
Load Chr(RecNo()+Ord('A')-1) as Alpha, RecNo() as Num autogenerate 26;

ASCII:
Load
 if(RecNo()>=65 and RecNo()<=90,RecNo()-64) as Num,
 Chr(RecNo()) as AsciiAlpha,
 RecNo() as AsciiNum
autogenerate 255
 Where (RecNo()>=32 and RecNo()<=126) or RecNo()>=160 ;

Transactions:
Load
 TransLineID,
 TransID,
 mod(TransID,26)+1 as Num,
 Pick(Ceil(3*Rand1),'A','B','C') as Dim1,
 Pick(Ceil(6*Rand1),'a','b','c','d','e','f') as Dim2,
 Pick(Ceil(3*Rand()),'X','Y','Z') as Dim3,
 Round(1000*Rand()*Rand()*Rand1) as Expression1,
 Round(  10*Rand()*Rand()*Rand1) as Expression2,
 Round(Rand()*Rand1,0.00001) as Expression3;
Load
 Rand() as Rand1,
 IterNo() as TransLineID,
 RecNo() as TransID
Autogenerate 1000
 While Rand()<=0.5 or IterNo()=1;
  ''';
  print(await global.createApp(testAppName, script: loadScript));
  var app = await global.getActiveDoc();
  print(app);
  if (app == null) {
    app = await global.openDoc(testAppName);
  }
  print(await app.doReloadEx());
  print(await app.doSave(fileName: testAppName));
  for (int n = 1; n <= counter; n++) {
    var id = n.toString().padLeft(4, '0');
    var vDef = new VariableDef(
        'Variable' + id, 'Sum(Expression2) * $n', 'Variable $id');
    print(await app.createVariableEx(vDef));
  }
//  var sheetMap = {
//    'qProp': {
//      'qMetaDef': {"title": "Sheet 1", "description": "Description of sheet 1"},
//      "qInfo": {"qId": "SH01", "qType": "sheet"}
//    }
//  };
//
//  print(await app.createObject(sheetMap));

  print(await app.saveObjects());
  engine.close();
}
