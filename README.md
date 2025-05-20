# carbonita

[![APEX Community](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/78c5adbe/badges/apex-community-badge.svg)](https://github.com/Dani3lSun/apex-github-badges) [![APEX Plugin](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/b7e95341/badges/apex-plugin-badge.svg)](https://github.com/Dani3lSun/apex-github-badges)
[![APEX Built with Love](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/7919f913/badges/apex-love-badge.svg)](https://github.com/Dani3lSun/apex-github-badges)


Carbonita is an Oracle Apex plugin [ #orclAPEX](https://apex.oracle.com) to generate office document  based on [Carbone](https://www.npmjs.com/package/carbone) ,

Carbonita use template to generate reports from queries or Interactive report in apex.
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
- Libreoffice installed on the server


### Steps

1. server install 
   1. option A : (manual install)
      1. install libreoffice on the nodejs server
         1. > sudo dnf install java-openjdk17
         2. > sudo dnf install python
         3. > sudo dnf install libreoffice
      2. node js
         1. > sudo dnf module install nodejs:22
      3. install carbonita package on nodejs
         1. copy folder carbonita/nodejs into the server 
         2. > npm install
         3. > node index.js
         4. (optional but required if in autonomous db) generate and copy ssl certificate 
   2. Option B : (docker/podman install)
      1. docker-compose up -d
2. install APEX application () 
3. configure and allow access from apex to the nodejs server
   1. set nodejs server url
   2. check network acl

## Knowns Issues

- bidirectionnal loop ()
  - Two dimensional loop (pivot unknow number of rows may not show correctly)
  - headers in bidirectionnal table may not show correctly.


## References & Credits

- [Carbone](https://carbone.io),
- [LibreOffice](https://www.libreoffice.org/)
- Badge credits: [Dani3lSun](https://github.com/Dani3lSun/apex-github-badges).
- AI including  https://chat.qwen.ai/, https://claude.ai , https://chatgpt.com

