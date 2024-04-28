/*
  version 0.10.5  2023-07-04
  - added https
  - use simplified code

*/

const express = require("express");
const https = require('https');
const http = require('http');
const fs = require('fs');
const app = express();
var favicon = require('serve-favicon');
var path = require('path')

const method_handler = require('./lib/lib-carbonita.js');


const PORT_HTTP = 80;
const PORT_HTTPS = 443;


/*
const options = {
  key: fs.readFileSync("./certs/server.key.pem"),
  cert: fs.readFileSync("./certs/server.pem")
}; 
*/


app.use(favicon(path.join(__dirname, 'favicon.ico')))

app.route('/')
  .get(method_handler.crbt_get)
  .post(method_handler.crbt_post);

// https listner is mandatory if used on Autonomous DB
// https.createServer(options, app).listen(PORT_HTTPS, () => {
//   console.log("HTTPS server is running at port " + PORT_HTTPS);
// });

http.createServer(app).listen(PORT_HTTP, () => {
  console.log("HTTP server is running at port " + PORT_HTTP);
});
