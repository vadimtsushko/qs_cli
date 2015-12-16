part of engine;


jw(Map map) => new JsonWrapper(map);
class JsonWrapper {
  Map map;
  JsonWrapper(this.map);
  JsonWrapper get(String key) {
    var res = map[key];
    if (res == null) {
      throw new Exception('Error! Map $map do not contain key "$key"');
    }
    return new JsonWrapper(res);
  }
  getValue(String key) {
    var res = map[key];
    if (res == null) {
      throw new Exception('Error! Map $map do not contain key "$key"');
    }
    return map[key];
  }


}