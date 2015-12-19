part of engine;

class Engine {
  final Logger logger= new Logger('Engine');
  int seqId = 0;
  WebSocket ws;
  bool closed = false;
  final Map<int, Completer> replyCompleters = new  Map<int, Completer>();
  Engine();
  Future<Global> init(String userId) async {
    ws = await WebSocket.connect("ws://localhost:8001/");
    ws.listen(onMessage);
    var completer = new Completer<Global>();
    replyCompleters[-1] = completer;
    ws.add('{"createProxy":"$userId"}');
    return completer.future;
  }
  onMessage(String message) {
    Map reply = JSON.decode(message);
    int id = reply['id'];
    if (id == null) {
      return;
    }
    var completer = replyCompleters.remove(reply['id']);
    assert(completer != null);
    if (id == -1) {
      completer.complete(new Global(this));
    } else {
      completer.complete(reply);
    }
  }

  Future<Map> query(int handle, String method, args) async {
    seqId++;

    var request = {
      'method': method,
      'handle': handle,
      'params': args,
      'id': seqId,
      'jsonrpc': '2.0'
    };
    return await rawQuery(request);
  }
  Future<Map> rawQuery(Map queryMessage) {
    Completer completer = new Completer();
    if (!closed) {
      assert(queryMessage['id'] != null);
      replyCompleters[queryMessage['id']] = completer;
      print(queryMessage);
      ws.add(JSON.encode(queryMessage));
    } else {
      completer.completeError(new Exception("Invalid state: Connection already closed."));
    }
    return completer.future;
  }

  close() {
    ws.close();
  }

}