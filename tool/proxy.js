var WebSocket = require('ws');

function Connection(serverWebSocket) {
  this.serverSocket = serverWebSocket;
  this.clientSocket = null;

}

Connection.prototype.init = function () {
    connection = this;
    connection.clientSocket = new WebSocket('ws://localhost:4848/app/TestInterface');
//    connection.clientSocket = new WebSocket('ws://192.168.188.10:4848/app/cb964130-12bb-476e-ac80-8b8ffa95f112/?qlikTicket=QDbtnc0jvR83lc1');

    connection.clientSocket.onerror = function (ev) {
        console.log('connection.clientSocket.onerror %s',ev);
        connection.clientSocket = null;
    };
    connection.clientSocket.onclose = function () {
        console.log('connection.clientSocket.onclose');
        connection.clientSocket = null;
    };
    connection.clientSocket.onmessage = function (ev) {
        connection.serverSocket.send(ev.data);
        console.log('<< %s', ev.data);

    };

    connection.clientSocket.onopen = function () {
        connection.serverSocket.send('{"id":-1, "message":"Connection opened"}');
    };

    connection.serverSocket.on('message', function(message) {
        console.log('>> %s', message);
        connection.clientSocket.send(message)
    });
    connection.serverSocket.on('close',function (code) {
        console.log('Closing connection with code: %s', code);
    });
};


var WebSocketServer = WebSocket.Server
  , wss = new WebSocketServer({port: 8001});
wss.on('connection', function(ws) {
  var conn = new Connection(ws);
  conn.init();

});