part of engine;

class Measure extends HandleObject{
  Measure(Engine engine, int handle): super(engine, handle);
  Future<Map> setProperties(MeasureDef measureDef) async {
    return await engine.query(handle,'SetProperties',measureDef.toJson());
  }
}