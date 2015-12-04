var qsocks = require('qsocks');
var fs = require('fs');
var request = require('request');
var WebSocket = require('ws');

function Connection(serverWebSocket, cookie) {
  this.serverSocket = serverWebSocket;
  this.clientSocket = null;
  this.cookie = cookie;

}

Connection.prototype.init = function () {
  connection = this;
//    connection.clientSocket = new WebSocket('ws://localhost:4848/app/TestInterface');
//    connection.clientSocket = new WebSocket('ws://192.168.188.10:4848/app/cb964130-12bb-476e-ac80-8b8ffa95f112/?qlikTicket=QDbtnc0jvR83lc1');
  var config = {
    headers:
    { 'Content-Type': 'application/json',
      Cookie: this.cookie }
  };
  console.log(config);
  connection.clientSocket = new WebSocket('ws://demo.inqlik.ru:8282/app/%3Ftransient%3D',null,config);
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

  connection.serverSocket.on('message', function(message) {
    console.log('>> %s', message);
    connection.clientSocket.send(message)
  });
  connection.serverSocket.on('close',function (code) {
    console.log('Closing connection with code: %s', code);
  });
};



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
  "UserId": 'vts',
  "Attributes": []
});
//console.log(b);
//  Get ticket for user - refer to the QPS API documentation for more information on different authentication methods.
console.log('Before post');

r.post({
  uri: 'https://demo.inqlik.ru:4243/qps/ticket?xrfkey=abcdefghijklmnop',
  body: b,
  headers: {
    'x-qlik-xrfkey': 'abcdefghijklmnop',
    'content-type': 'application/json'
  }
},
function(err, res, body) {
//  console.log(res);
//  console.log(body);

  //  Consume ticket, set cookie response in our upgrade header against the proxy.
  console.log(body);
  var ticket = JSON.parse(body)['Ticket'];
//  console.log('Before get ticket');

  r.get('https://demo.inqlik.ru:8282/hub/?qlikTicket=' + ticket, function(error, response, body) {

    var cookies = response.headers['set-cookie'];
    console.log(cookies);

    //  qsocks config, merges into standard https/http object headers.
    //  Set the session cookie correctly.
    //  The origin specified needs an entry in the Whitelist for the virtual proxy to allow websocket communication.
    var config = {
      host: 'demo.inqlik.ru',
      port: 8282,
      isSecure: false,
      origin: 'http://localhost',
      rejectUnauthorized: false,
      headers: {
        "Content-Type": "application/json",
        "Cookie": cookies[0]
      }
    }

    var WebSocketServer = WebSocket.Server
        , wss = new WebSocketServer({port: 8001});
    wss.on('connection', function(ws) {
      var conn = new Connection(ws, cookies[0]);
      conn.init();
    });


  })

});




