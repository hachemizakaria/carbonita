/*

*/
var version = '0.10.7';

var carbonita_js = {
    base64toBlob: function (pBase64, pMimeType) {
        var byteCharacters = atob(pBase64);
        var byteNumbers = new Array(byteCharacters.length);
        for (var i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        var byteArray = new Uint8Array(byteNumbers);
        try {
            return new Blob([byteArray], { type: pMimeType });
        } catch (e) {
            if (typeof window.BlobBuilder !== "undefined") {
                var bb = new BlobBuilder();
                bb.append(byteArray.buffer);
                return bb.getBlob(pMimeType);
            } else {
                throw new Error("Blob creation is not supported.");
            }
        }
    },

    clob2Array: function (clob, size, array) {
        var loopCount = Math.floor(clob.length / size) + 1;
        for (var i = 0; i < loopCount; i++) {
            array.push(clob.slice(size * i, size * (i + 1)));
        }
        return array;
    },

    carbonita_function: function () { //daContext, options

        console.log('version ' + version);
        console.log('started !');
        var spinner = apex.util.showSpinner();


        var daThis = this;
        //? trigger = "#"+this.triggeringElement.id;


        var v_AjaxIdentifier = daThis.action.ajaxIdentifier;

        // variables recieved from render

        var v_output_filename = daThis.action.attribute01;


        var v_items_to_submit = daThis.action.attribute02;

   

        // APEX Ajax Call
        apex.server.plugin(v_AjaxIdentifier, {

            x01:  v_output_filename,

            pageItems: v_items_to_submit //"#P1_DEPTNO,#P1_EMPNO", template

        }, {
            success: function (DataFromAjax) {

                // console.log(DataFromAjax);  // debug

                $('body').trigger('carbonita-report-received');

                var x_report_mimetype = DataFromAjax.reportgenerated.mimetype;
                var x_report_base64 = DataFromAjax.reportgenerated.base64;


                try {
                    var reportblob = carbonita_js.base64toBlob(x_report_base64, x_report_mimetype);
                    if (DataFromAjax.download === 'js') {
                        saveAs(reportblob, v_output_filename);

                        //remove spinner
                        spinner.remove();
                    }
                } catch (error) {
                    console.log('error file');
                    console.log(error);
                    spinner.remove();
                }

            },
            error: function (xhr, pMessage) {
                //remove spinner
                spinner.remove();
                // add apex event
                $('body').trigger('carbonita-report-error-01');
                // logging
                console.log('dothejob: apex.server.plugin ERROR:', pMessage);
                // callback();
            }
        });


    }
}