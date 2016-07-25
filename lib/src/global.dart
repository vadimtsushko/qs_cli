part of engine;

class Global extends HandleObject {
  Global(Engine engine) : super(engine, -1);
  Future<Application> openDoc(String appName) async {
    var reply = await engine.query(-1, 'OpenDoc', [appName]);
    print('openDoc $reply');
    int docHandle = _getDocHandle(reply);
    if (docHandle == null) {
      return null;
    }
    return new Application(engine, docHandle, appName);
  }
  _getDocHandle(Map response) {
    if (response['result'] == null) {
      return null;
    }
    if (response['result']['qReturn'] == null) {
      return null;
    }
    return response['result']['qReturn']['qHandle'];
  }
  Future<Application> getActiveDoc() async {
    var reply = await query('GetActiveDoc', {});
    print(reply);
    int docHandle = _getDocHandle(reply);
    if (docHandle == null) {
      return null;
    }
    return new Application(engine, docHandle, '');
  }

  Future<Map> createApp(String appName, {String script: ''}) async =>
      await query('CreateApp',
          {"qAppName": appName + '.qvf', "qLocalizedScriptMainSection": script});
  Future<Map> deleteApp(String appId) async =>
      await query('DeleteApp', {"qAppId": appId + '.qvf'});

  Future<List<DocListEntry>> getDocList() async {
    var jsonReply = await query('GetDocList', {});
    List<DocListEntry> result = <DocListEntry>[];
    for (Map each in jsonReply['result']['qDocList']) {
      result.add(new DocListEntryDecoder().convert(each));
    }
    return result;
  }
}
