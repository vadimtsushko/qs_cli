var ws = require("ws")

// Scream server example: "hi" -> "HI!!!"
// var server = ws.createServer(function (conn) {
//     console.log("New connection")
//     conn.on("text", function (str) {
//         console.log("Received "+str)
//         conn.sendText(str.toUpperCase()+"!!!")
//     })
//     conn.on("close", function (code, reason) {
//         console.log("Connection closed")
//     })
// }).listen(8001)
function Connection(serverWebSocket) {

  this.serverSocket = serverWebSocket;
  this.clientSocket = null;
}

Connection.prototype.init = function () {
    connection = this;
    connection.serverSocket.on('message', function(message) {
        console.log('received: %s', message);
        connection.serverSocket.send(message.toUpperCase() + '!!!')
    });
    connection.serverSocket.on('close',function (code, message) {
        console.log('Closing connection with code: %s', code);
    });
    connection.serverSocket.send('something');
}

var qs;
var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({port: 8001});
wss.on('connection', function(ws) {
  var conn = new Connection(ws);
  conn.init();

});