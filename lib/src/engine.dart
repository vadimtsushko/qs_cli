part of engine;

class Engine {
  final Logger logger = new Logger('Engine');
  int seqId = 0;
  WebSocket ws;
  bool closed = false;
  final Map<int, Completer> replyCompleters = new Map<int, Completer>();
  Engine();

  Future<Global> init(String host, String userDir, String userId) async {
    var ticketInfo = await Process.run('SenseTicket', [host, userDir, userId]);
    ticketInfo = JSON.decode(ticketInfo.stdout);
    var ticket = ticketInfo['Ticket'];
    var response = await http.get('http://$host/hub/?qlikTicket=' + ticket);
    var cookie = response.headers['set-cookie'];

    var headers = {'Content-Type': 'application/json', 'Cookie': cookie};
    print('init cookie; $cookie');
    ws = await WebSocket.connect('ws://$host/app/%3Ftransient%3D',
        headers: headers);
    ws.listen(onMessage, onError: onError);
    return new Global(this);
  }

  Future<String> getTicket(String host, String userDir, String userId) async {
    var ticketInfo = await Process.run('SenseTicket', [host, userDir, userId]);
    ticketInfo = JSON.decode(ticketInfo.stdout);
    return ticketInfo['Ticket'];
  }

  onError(error) {
    print(error);
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
      ws.add(JSON.encode(queryMessage));
    } else {
      completer.completeError(
          new Exception("Invalid state: Connection already closed."));
    }
    return completer.future;
  }

  close() async {
    return ws.close();
  }

  Future<Map> queryList(int handle, String method, args) async {
    return await query(handle, method, [args]);
  }
}
