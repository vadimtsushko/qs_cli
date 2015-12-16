var fs = require('fs');
var request = require('request');
var WebSocket = require('ws');

function Connection(serverWebSocket, cookie) {
  this.serverSocket = serverWebSocket;
  this.clientSocket = null;
  this.cookie = cookie;
  this.initialized = false;
  this.userId = null;
}


Connection.prototype.initProxy = function () {
  connection = this;

  //  Set our request defaults, ignore unauthorized cert warnings as default QS certs are self-signed.
//  Export the certificates from your Qlik Sense installation and refer to them
  var r = request.defaults({
    rejectUnauthorized: false,
    host: '192.168.188.10',
    pfx: fs.readFileSync(__dirname + '\\client.pfx')
  })

//console.log(r);

//  Authenticate whatever user you want
  var b = JSON.stringify({
    "UserDirectory": 'SERV10',
    "UserId": connection.userId,
    "Attributes": []
  });
//console.log(b);
//  Get ticket for user - refer to the QPS API documentation for more information on different authentication methods.
  console.log('Before post');

  r.post({
        uri: 'https://192.168.188.10:4243/qps/ticket?xrfkey=abcdefghijklmnop',
        body: b,
        headers: {
          'x-qlik-xrfkey': 'abcdefghijklmnop',
          'content-type': 'application/json'
        }
      },
      function(err, res, body) {
        //  Consume ticket, set cookie response in our upgrade header against the proxy.
        console.log(body);
        var ticket = JSON.parse(body)['Ticket'];
        r.get('https://192.168.188.10/hub/?qlikTicket=' + ticket, function(error, response, body) {

          var cookies = response.headers['set-cookie'];
          console.log(cookies);
          var config = {
            headers:
            { 'Content-Type': 'application/json',
              Cookie: cookies }
          };
          console.log(config);
          connection.clientSocket = new WebSocket('ws://192.168.188.10/app/%3Ftransient%3D',null,config);
          connection.clientSocket.onerror = function (ev) {
            console.log('connection.clientSocket.onerror %s',ev);
            connection.clientSocket = null;
          };
          connection.clientSocket.onclose = function () {
            console.log('connection.clientSocket.onclose');
            connection.clientSocket = null;
          };
          connection.clientSocket.onmessage = function (ev) {
            if (connection.serverSocket.readyState !== WebSocket.OPEN) {
              console.log('WARNING!!! Server socket is closed');
              console.log('<< %s', ev.data);
            } else {
              connection.serverSocket.send(ev.data);
              console.log('<< %s', ev.data);
            }

          };

          connection.clientSocket.onopen = function () {
            connection.serverSocket.send('{"id":-1, "message":"Connection opened"}');
          };
        })
      });
}

Connection.prototype.init = function () {
  connection = this;
  connection.serverSocket.on('message', function(message) {
    if (!connection.initialized) {
      var msg = JSON.parse(message);
      console.log(msg);
      var userId = msg['createProxy'];
      if (!userId) {
        console.log('{"error": "Unrecognized initial command: %s"}', message);
        connection.serverSocket.send('{"error": "ERROR! Unrecognized initial command, id: 1"}');
        connection.serverSocket.close();
        return;
      } else {
        connection.userId = userId;
        connection.initProxy();
        connection.initialized = true;

        return;
      }
    }
    console.log('>> %s', message);
    connection.clientSocket.send(message)
  });
  connection.serverSocket.on('close',function (code) {
    connection.clientSocket.close();
    console.log('Closing connection with code: %s', code);
  });
};





var WebSocketServer = WebSocket.Server
    , wss = new WebSocketServer({port: 8001});
wss.on('connection', function(ws) {
  var conn = new Connection(ws);
  conn.init();
});


