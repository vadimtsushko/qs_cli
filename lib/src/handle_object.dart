part of engine;
class HandleObject {
  Engine engine;
  int handle;
  HandleObject(this.engine, this.handle);
  String toString() => '${this.runtimeType}(handle: $handle)';
  query(String method, Map params) => engine.query(handle, method, params);
}