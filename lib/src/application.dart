part of engine;

class Application extends HandleObject {
  final String appName;
  Application(Engine engine, int handle, this.appName) : super(engine, handle);
  String toString() => 'Application($handle, $appName)';
  Future<Map> createMeasure(MeasureDef measure) async {
    var reply = await engine.query(handle, 'CreateMeasure', measure.toJson());
    return reply;
  }

  Future<Map> createVariableEx(VariableDef varDef) async =>
      await query('CreateVariableEx', varDef.toJson());
  Future<Map> createObject(params) async => await query('CreateObject', params);

  Future<Map> updateVariable(VariableDef varDef) async {
    var varMap = await getVariableByName(varDef.name);
    int handle = jw(varMap).get('result').get('qReturn').getValue('qHandle');
    return await new Variable(this.engine, handle).setProperties(varDef);
  }

  Future<Map> getVariableByName(String name) async =>
      await query('GetVariableByName', {'qName': name});

  Future<Measure> getMeasure(String id) async {
    var reply = await engine.query(handle, 'GetMeasure', {'qId': id});
    int mHandle = reply['result']['qReturn']['qHandle'];
    if (mHandle == null) {
      return null;
    }
    return new Measure(engine, mHandle);
  }

  Future<Map> destroyVariableByName(String name) async {
    return await query('DestroyVariableByName', {'qName': name});
  }

  Future<Map> saveObjects() async {
    return await query('SaveObjects', {});
  }

  Future<Map> doReloadEx(
      {int mode: 0, bool partial: false, bool debug: false}) async {
    return await query(
        'DoReload', {"qMode": mode, "qPartial": partial, "qDebug": debug});
  }

  Future<Map> doSave({String fileName: ''}) async {
    return await query('DoSave', {"qFileName": fileName});
  }

  Future<Map> createOrUpdateMeasure(MeasureDef mDef) async {
    var measure = await getMeasure(mDef.id);
    Map reply;
    if (measure == null) {
      reply = await createMeasure(mDef);
    } else {
      reply = await measure.setProperties(mDef);
    }
    return reply;
  }

  Future<Map> updateMeasure(MeasureDef mDef) async {
    var measure = await getMeasure(mDef.id);
    Map reply;
    if (measure == null) {
      throw new Exception('Not found measure: ${mDef.id}');
    } else {
      reply = await measure.setProperties(mDef);
    }
    return reply;
  }

  Future<List<VariableDef>> getVariables(
      {String filterTag: '', bool excludeScriptCreated: true}) async {
    var result = new List<VariableDef>();
    var varList = await this.query('CreateSessionObject', {
      "qProp": {
        "qInfo": {"qType": "VariableList"},
        "qVariableListDef": {
          "qType": "variable",
          "qShowReserved": true,
          "qShowConfig": true,
          "qData": {"tags": "/tags"}
        }
      }
    });
    var varListHandle = new JsonWrapper(varList)
        .get('result')
        .get('qReturn')
        .getValue('qHandle');
    var varList1 = await this.engine.query(varListHandle, 'GetLayout', {});
    var varList2 = jw(varList1)
        .get('result')
        .get('qLayout')
        .get('qVariableList')
        .getValue('qItems');
    for (var each in varList2) {
      if (!excludeScriptCreated || each['qIsScriptCreated'] != true) {
        String name = jw(each).getValue('qName');
        String definition = each['qDefinition'];
        String description = each['qDescription'];
        result.add(new VariableDef(name, definition, description));
      }
    }
    return result;
  }

  Future<Map> destroyMeasure(String id) async {
    return await query('DestroyMeasure', {'qId': id});
  }

  Future<List<String>> getMeasures(
      {String filterTag: '', bool excludeScriptCreated: true}) async {
    var result = new List<String>();

    var param = {
      "qInfo": {"qType": "MeasureList"},
      "qMeasureListDef": {
        "qType": "measure",
        "qData": {
          "title": "/title",
          "expressions": "/expressions",
          "tags": "/tags"
        }
      }
    };
    var varList =
        await this.engine.queryList(this.handle, 'CreateSessionObject', param);
    var varListHandle = new JsonWrapper(varList)
        .get('result')
        .get('qReturn')
        .getValue('qHandle');
    var varList1 = await this.engine.query(varListHandle, 'GetLayout', {});

    var varList2 = jw(varList1)
        .get('result')
        .get('qLayout')
        .get('qMeasureList')
        .getValue('qItems');
    for (var each in varList2) {
//      if (filter || each['qIsScriptCreated'] != true) {
      String id = jw(each).get('qInfo').getValue('qId');
//        String definition = jw(each).getValue('qDefinition');
//        String description = each['qDescription'];
      result.add(id);
//      }
    }
    return result;
  }
}
