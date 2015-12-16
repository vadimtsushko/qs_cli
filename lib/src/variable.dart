part of engine;
class Variable extends HandleObject{
  Variable(Engine engine, int handle): super(engine, handle);
  Future<Map> setProperties(VariableDef variableDef) async {
    return await engine.query(handle,'SetProperties',variableDef.toJson());
  }
}