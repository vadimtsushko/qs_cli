part of engine;

class Application {
  Engine engine;
  final int handle;
  final String appName;
  Application(this.engine, this.handle, this.appName);
  String toString() => 'Application($handle, $appName)';
  Future<Map> createMeasure(Measure measure) async {
    var reply = await engine.query(handle,'CreateMeasure',measure.toJson());
    return reply;
  }
  Future<Map> saveObjects() async {
    return await engine.query(handle,'SaveObjects',{});
  }
}