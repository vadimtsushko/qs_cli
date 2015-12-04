import "package:dart_qv/engine.dart";

final counter = 3;
main() async {
  final testAppName = 'DimensionSample$counter';
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
  res = await global.createApp(testAppName, script: loadScript);
  print('CreateApp result: $res');
  var appId = res['result']['qAppId'];
  print(appId);
  var app = await global.getActiveDoc();
  print(app);
  if (app == null) {
    app = await global.openDoc(appId);
  }
  print(await app.doReloadEx());
  print(await app.doSave(fileName: appId));
  //print(await app.doSave());
  for (int n = 1; n <= counter; n++) {
    var id = n.toString().padLeft(4,'0');
    var mDef = new MeasureDef('Measure'+id, 'Sum(Expression2) * $n', 'Measure $id',
        description: 'Extended description for meausure $id');
    print(await app.createOrUpdateMeasure(mDef));
  }
  print(await app.saveObjects());
  engine.close();
}
