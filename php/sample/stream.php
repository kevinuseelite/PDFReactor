<?php
    // Include PDFreactor class
    require_once("../lib/PDFreactor.class.php");

    use com\realobjects\pdfreactor\webservice\client\PDFreactor as PDFreactor;
    use com\realobjects\pdfreactor\webservice\client\PDFreactorWebserviceException as PDFreactorWebserviceException;
    use com\realobjects\pdfreactor\webservice\client\LogLevel as LogLevel;
    use com\realobjects\pdfreactor\webservice\client\ViewerPreferences as ViewerPreferences;

    // The content to render
    $content = implode(file('../../resources/contentPHP.html'));

    date_default_timezone_set('CET');

    // Create new PDFreactor instance
    // $pdfReactor = new PDFreactor("http://yourServer:9423/service/rest");
    $pdfReactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");

    $config = array(
        // Specify the input document
        "document"=> $content,
        // Set a base URL for images, style sheets, links
        "baseURL"=> "http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"],
        // Set an appropriate log level
        "logLevel"=> LogLevel::DEBUG,
        // Set the title of the created PDF
        "title"=> "Demonstration of PDFreactor PHP API",
        // Sets the author of the created PDF
        "author"=> "Myself",
        // Set some viewer preferences
        "viewerPreferences"=> array(
            ViewerPreferences::FIT_WINDOW,
            ViewerPreferences::PAGE_MODE_USE_THUMBS
        ),
        // Add user style sheets
        "userStyleSheets"=> array(
            array(
                'content'=> "@page {" .
                                "@top-center {".
                                    "content: 'PDFreactor PHP API demonstration';".
                                "}".
                                "@bottom-center {" .
                                    "content: 'Created on ".date("m/d/Y G:i:s A")."';" .
                                "}" .
                            "}"
            ),
            array( 'uri'=> "../../resources/common.css" )
        )
    );

    try {
        // Sync
        $file1Name = 'stream-sync.pdf';
        $file1 = fopen($file1Name, 'w');

        if (!$file1) {
            throw new Exception("Could not write '".$file1Name."'. Check your file system permissions.");
        }

        $pdfReactor->convertAsBinary($config, $file1);

        // Async
        $connectionSettings = array();
        $documentId = $pdfReactor->convertAsync($config, $connectionSettings);
        $progress = null;

        do {
            sleep(0.5);
            $progress = $pdfReactor->getProgress($documentId, $connectionSettings);
        } while (!$progress->finished);

        $file2Name = 'stream-async.pdf';
        $file2 = fopen($file2Name, 'w');

        if (!$file2) {
            throw new Exception("Could not write '".$file2Name."'. Check your file system permissions.");
        }

        $pdfReactor->getDocumentAsBinary($documentId, $file2, $connectionSettings);

        header("Content-Type: text/html");
        echo "<h1>2 files successfully written: '".$file1Name."' and '".$file2Name."'. Please check your file system.</h1>";
    } catch (PDFreactorWebserviceException $e) {
        header("Content-Type: text/html");
        echo "<h1>An Error Has Occurred</h1>";
        echo "<h2>".$e->getMessage()."</h2>";
    }
?>
