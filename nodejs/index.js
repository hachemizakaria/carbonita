/*
  VERSION = "0.7.70"; 2025-05-17
  - refractor using qwen
  - SIGINT
  - added https
  - use simplified code

*/

const express = require("express");
const https = require('https');
const http = require('http');
const fs = require('fs');
const app = express();

const path = require('path');

const method_handler = require('./lib/carbonita-lib.js');

const PORT_HTTP = 80;
const PORT_HTTPS = 443; // mandatory on apex.oracle.com and ADB

// Load SSL certs
let options;
try {
  options = {
  key: fs.readFileSync("./certs/server.key.pem"),
  cert: fs.readFileSync("./certs/server.pem")
}; 
} catch (err) {
  console.error("SSL certificate load failed:", err.message);
  process.exit(1);
}



app.route('/')
  .get(method_handler.method_get)
  .post(method_handler.method_post);


const servers = [
  https.createServer(options, app).listen(PORT_HTTPS),
  http.createServer((req, res) => {
    res.writeHead(301, { "Location": `https://${req.headers.host}${req.url}` });
    res.end();
  }).listen(PORT_HTTP)
];
console.log(`HTTPS server running on port ${PORT_HTTPS}`);
console.log(`HTTP redirect server running on port ${PORT_HTTP}`);


process.on('SIGINT', () => {
  console.log("\nGracefully shutting down...");
  servers.forEach(server => server.close());
  process.exit(0);
});
