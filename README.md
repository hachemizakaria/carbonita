# carbonita

pdf generator for oracle apex #orclAPEX based on carbone,

Based on [Carbone](https://carbone.io)  , Carbonita use template to generate reports from queries or Interactive report in apex.
The generated reports can be PDF, DOCX, or XLSX.

## Description

carbonita generate pdf, docx, xlsx report whithin apex application
This application use nodejs server side rendering , which use libreoffice.

## Demo

demo application : https://apex.oracle.com/pls/apex/r/hachemi/carbonita
username demo
password password123

## installation

### Requirements

- Oracle APEX
- NodeJS
- Libreoffice
- Carbone package on nodejs

### Steps

1. install node js
   1. dnf module install nodejs:14
2. install libreoffice on the nodejs server
   1. dnf install libreoffice
3. install carbonita package on node js
   1. copy folder carbonita/nodejs
   2. npm install
   3. node index.js
4. install application on apex
5. Allow access from apex to the nodejs server

## Knowns Issues

- bidirectionnal loop
  - Two dimensional loop (pivot unknow number of rows may not show correctly)
  - headers in bidirectionnal table may not show correcly.

## TODO

- [x] https
- [x] plugin da
- [x] master details
- [x] nodeserver as service
- [x] parameters
- [ ] template 0 from report/query
- [ ] data from context IR
- [ ] Oauth / security to access, Service as REST

## References & Credits

- [Carbone](https://carbone.io),
- [LibreOffice](https://www.libreoffice.org/)
- [AmandaDocxPrinter](https://github.com/aldocano29/AmandaDocxPrinter)
- [Creating a REST API with Node.js and Oracle Database](https://jsao.io/2018/03/creating-a-rest-api-with-node-js-and-oracle-database/)
- [Uploading and Downloading Files with Node.js and Oracle Database](https://jsao.io/2019/06/uploading-and-downloading-files-with-node-js-and-oracle-database)
