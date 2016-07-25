part of engine;

class GenericObject extends HandleObject{
  GenericObject(Engine engine, int handle): super(engine, handle);
  Future<Map> getFullPropertyTree() async {
    return await engine.query(handle,'GetFullPropertyTree',{});
  }
}