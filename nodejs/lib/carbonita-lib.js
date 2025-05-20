
/**
 * * verion 0.7.82 2025-05-11
 *    - Added support for postman
 *    - refractored using qwen
 */

/**
 * 
 * POST handler parameters
@templateContent  : file
@templateEncoding : text : binary, base64
@jsonData         : text
@reportName       : text
@outputFormat     : text
 */

const formidable = require("formidable");
const { promises: fs } = require("fs");
const { join } = require("path");
const { tmpdir } = require("os");
const carbone = require("carbone");
const mime = require("./mimestypes-lib");
const util = require("util");
const { v4: uuidv4 } = require("uuid");

const VERSION = "0.7.82";

const renderAsync = util.promisify(carbone.render).bind(carbone);

function parseDataHierarchically(dataString) { // OLD for nested json 
  const parsedData = JSON.parse(dataString);

  const parseNestedJSON = (value) => {
    try {
      return JSON.parse(value);
    } catch (e) {
      return value;
    }
  };

  const parseObject = (obj) => {
    for (let key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = parseNestedJSON(obj[key]);
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        parseObject(obj[key]);
      }
    }
  };

  parseObject(parsedData);
  return parsedData;
}
/*
async function method_get(req, res) {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end("<h1>Hello, I am carbonita. version " + VERSION + " </h1>");
}*/

async function method_get(req, res) {


  try {
    let htmlContent = await fs.readFile('index.html', 'utf8');
    // Replace a placeholder in your HTML with the VERSION
    htmlContent = htmlContent.replace('{{VERSION}}', VERSION);
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(htmlContent);
  } catch (err) {
    console.error('Error reading index.html:', err);
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end('Internal Server Error');
  }
}


async function method_post(req, res) {
  let templatePath = null;
  let resultBuffer = null;

  try {
    const form = new formidable.IncomingForm({ multiples: true });

    const { fields, files } = await new Promise((resolve, reject) => {
      form.parse(req, (err, fields, files) => {
        if (err) reject(err);
        else resolve({ fields, files });
      });
    });
    //console.info("", fields);
    // Validate required inputs
    if (!fields.jsonData || !files.templateContent || !files.templateContent[0]) {
      throw new Error("Missing required fields: jsonData or templateContent");
    }

    const report = {
      data:
        //parseDataHierarchically(fields.jsonData[0]), ??   
        JSON.parse(fields.jsonData[0]), // 

      reportName: fields.reportName?.[0] || "result",
      reportType: fields.outputFormat?.[0] || "pdf",
      mimeType: mime.get_mime(fields.outputFormat?.[0]) || "application/octet-stream",
    };

    // Handle template encoding
    if (fields.templateEncoding?.[0] === "binary") {
      templatePath = files.templateContent[0].filepath;
    } else {
      templatePath = await convertBase64ToBinary(files.templateContent[0].filepath);
    }

    // Render the report
    resultBuffer = await renderAsync(templatePath, report.data, {
      convertTo: report.reportType,
    });

    // Build JSON response with base64-encoded result
    const base64Result = resultBuffer.toString("base64");
    const userAgent = req.headers['user-agent'];
    const buffer = Buffer.from(base64Result, 'base64');


    // Adding support for testing from postman
    if (userAgent !== 'APEX') {
      res.setHeader("Content-Type", report.mimeType);
      res.statusCode = 200;
      res.end(buffer);
    } else {

      res.setHeader("Content-Type", "application/json");
      res.statusCode = 200;

      res.end(JSON.stringify({
        status: "success",
        download: "js",
        debug: {
          formatValue: report.reportType,
          submitedItems: Object.keys(fields),
        },
        reportgenerated: {
          mimetype: report.mimeType,
          filename: report.reportName,
          base64: base64Result

        },
      })
      );

    }


    // Clean up
    if (templatePath && templatePath !== files.templateContent[0].filepath) {
      await fs.unlink(templatePath);
    }

  } catch (error) {
    console.error("Error processing request:", error);
    res.writeHead(500, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      status: "error",
      message: error.message,
    }));
  }
}

async function convertBase64ToBinary(filePath) {
  try {
    const buffer = await fs.readFile(filePath);
    const base64String = buffer.toString("utf8");
    const binaryBuffer = Buffer.from(base64String, "base64");

    const newPath = join(tmpdir(), `${uuidv4()}-template.docx`);
    await fs.writeFile(newPath, binaryBuffer);
    await fs.unlink(filePath);

    return newPath;
  } catch (error) {
    throw new Error(`Base64 conversion failed: ${error.message}`);
  }
}

module.exports.method_post = method_post;
module.exports.method_get = method_get;