/*
  version 0.10.5  2023-07-04
  
  logic :
  - receive fields and files 
  - render using carbone , libreoffice
  - send back rendered file

  bugs :
    - options work on windows but do not work on some linux 
        workarrouand : install rpm libreoffice and install yum 
*/

const formidable = require("formidable");
const { promises: fs } = require("fs");
const carbone = require("carbone");
const mime = require("./lib-mimestypes");
const util = require("util");

const version = "0.9.104";

async function c_get(req, res) {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end("<h1>Hello, I am carbonita. version " + version + " </h1>");
}

async function c_post(req, res) {
  try {
    const form = new formidable.IncomingForm({ multiples: true });

    const { fields, files } = await new Promise((resolve, reject) => {
      form.parse(req, (err, fields, files) => {
        if (err) {
          reject(err);
        } else {
          resolve({ fields, files });
        }
      });
    });

    const report = {};

    if (fields.req_encoding === "binary") {
      report.template_path = files.template_binary.filepath;
    } else {
      report.template_path = await convert_base64(
        files.template_binary.filepath
      );
    }

    report.result_path = `./result-${add()}.${fields.report_type}`;
    report.data = JSON.parse(fields.data_text);
    report.report_name = fields.report_name || "result";
    report.report_type = fields.report_type || "txt";
    report.mimetype = mime.get_mime(report.report_type);

    console.log("Starting rendering...");

    var options = {
      convertTo: report.report_type,
      hardRefresh: true,
    };

    const result = await util.promisify(carbone.render)(
      report.template_path,
      report.data,
      options
    );
    console.log("Rendering completed.");

    await fs.unlink(report.template_path);
    await fs.writeFile(report.result_path, result);

    console.log("File write completed.");

    res.setHeader("Content-Type", report.mimetype);
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${report.report_name}"`
    );
    res.statusCode = 200;
    res.end(result);

    console.log("Response sent.");

    if (1 === 1) {
      await fs.unlink(report.result_path);
      console.log("Successfully removed result: " + report.result_path);
    }

    console.log("-end-");
    console.log("-----");
  } catch (error) {
    res.writeHead(500, {
      "Content-Type": "application/json",
      "Content-Disposition": 'attachment; filename="error.json"',
    });
    res.end(JSON.stringify({ error: error.message }));
    console.log("Error occurred:", error);
  }
}

const add = (function () {
  let counter = 0;
  return function () {
    counter += 1;
    return counter;
  };
})();

async function convert_base64(path) {
  const data = await fs.readFile(path, "utf8");
  const bin = Buffer.from(data, "base64");
  const newpath = `${path}-n-f05-binary`;

  await fs.writeFile(newpath, bin, "binary");

  if (1 === 1) {
    await fs.unlink(path);
    console.log("Successfully removed base64 template: " + path);
  }

  return newpath;
}

module.exports.crbt_post = c_post;
module.exports.crbt_get = c_get;
