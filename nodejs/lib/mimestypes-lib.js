

expected_mimetypes = {
    pdf: "application/pdf",
    docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    txt: "text/plain",
    ods: "application/vnd.oasis.opendocument.spreadsheet",
    odt: "application/vnd.oasis.opendocument.text",
    default: "text/plain"
};

function get_mime(extension) {
    return expected_mimetypes[extension || 'default'] || 'test/plain';
}

module.exports.get_mime = get_mime;