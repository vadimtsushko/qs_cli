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
  Future<Map> createObject(params) async =>
      await query('CreateObject', params);


  Future<Measure> getMeasure(String id) async {
    var reply = await engine.query(handle, 'GetMeasure', {'qId': id});
    int mHandle = reply['result']['qReturn']['qHandle'];
    if (mHandle == null) {
      return null;
    }
    return new Measure(engine, mHandle);
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
}
