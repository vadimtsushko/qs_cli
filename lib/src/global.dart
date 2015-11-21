part of engine;

class Global {
  Engine engine;
  final handle = -1;
  Global(this.engine);
  Future<Application> openDoc(String appName) async {
    var reply = await engine.query(-1, 'OpenDoc', [appName]);
    int handle = reply['result']['qReturn']['qHandle'];
    assert(handle != null);
    var result = new Application(engine,handle, appName);
    return result;
  }
}