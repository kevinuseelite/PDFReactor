const PDFreactor = require("../lib/PDFreactor.js");
const fs = require('fs');
const path = require('path');

// Create new PDFreactor instance
// var pdfReactor = new PDFreactor("http://yourServer:9423/service/rest");
var pdfReactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");

fs.readFile('../../resources/contentNodeJs.html', 'utf8', async (error, content) => {
    if (error) {
        return console.log(error);
    }

    // Construct the base URL, using the current path.
    var basePath = path.resolve(".");
    if (!basePath.startsWith("/")) {
        basePath = "file:///" + basePath.replace(/\\/g, "/");
    } else {
        basePath = "file://" + basePath;
    }
    if (!basePath.endsWith("/")) {
        basePath += "/";
    }

    var config = {
        document: content,
        // Set a base URL for images, style sheets, links
        baseURL: basePath,
        // Set an appropriate log level
        logLevel: PDFreactor.LogLevel.WARN,
        // Set the title of the created PDF
        title: "Demonstration of the PDFreactor Node.js API",
        // Set the author of the created PDF
        author: "Myself",
        // Set some viewer preferences
        viewerPreferences: [
            PDFreactor.ViewerPreferences.FIT_WINDOW,
            PDFreactor.ViewerPreferences.PAGE_MODE_USE_THUMBS
        ],
        // Add user style sheets
        userStyleSheets: [
            {
                content: "@page {" +
                             "@top-center {" +
                                 "content: 'PDFreactor Node.js API demonstration';" +
                             "}" +
                             "@bottom-center {" +
                                 "content: 'Created on " + new Date().toLocaleString() + "';" +
                             "}" +
                         "}"
            },
            { uri: "../../resources/common.css" }
        ]
    }

    try {
        // Convert document
        const result = await pdfReactor.convert(config);

        fs.writeFile('simple.pdf', result.document, 'base64', function(error) {
            if (error) {
                return console.log(error);
            }
            console.log("Conversion completed. Resulting PDF has " + result.numberOfPagesLiteral + " pages.");
        });
    } catch (e) {
        if (e instanceof PDFreactor.PDFreactorWebserviceError) {
            console.log(e.message);
        }
    }
});
