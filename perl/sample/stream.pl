#!/usr/bin/perl -w
use Time::Piece;
my $time = Time::Piece->new()->strftime('%m/%d/%Y %H:%M:%S');

use Cwd qw(abs_path);
use File::Basename;
my $directory = dirname(dirname(abs_path($0)))."/lib/";
require $directory."PDFreactor.pm";

# The content to render
open(CONTENT, dirname(dirname($directory))."/resources/contentPerl.html");
@arrcontent = <CONTENT>;
close CONTENT;
$content = join "", @arrcontent;

# Create new PDFreactor instance
# my $pdfReactor = PDFreactor->new("http://yourServer:9423/service/rest");
my $pdfReactor = PDFreactor->new("https://cloud.pdfreactor.com/service/rest");

# Get the current URL path
my $path = $ENV{'REQUEST_URI'};

# If the first environment variable does not exist
if ($path eq "") {
    # try another variable.
    $path = $ENV{'PATH_INFO'};
}

$config = {
    # Specify the input document
    'document' => $content,
    # Set a base URL for images, style sheets, links
    'baseURL' => "http://".$ENV{'HTTP_HOST'}.$path,
    # Set an appropriate log level
    'logLevel' => PDFreactor::LogLevel->WARN,
    # Set the title of the created PDF
    'title' => 'Demonstration of the PDFreactor Perl API',
    # Set the author of the created PDF
    'author' => 'Myself',
    # Set some viewer preferences
    'viewerPreferences' => [
        PDFreactor::ViewerPreferences->FIT_WINDOW,
        PDFreactor::ViewerPreferences->PAGE_MODE_USE_THUMBS
    ],
    # Add user style sheets
    'userStyleSheets' => [
        {
            'content' => '@page {'.
                             '@top-center {'.
                                    'content: "PDFreactor Perl API demonstration";'.
                             '}'.
                             '@bottom-center {'.
                                 'content: "Created on '.$time.'";'.
                             '}'.
                         '}'
        },
        { 'uri' => "../../resources/common.css" }
    ]
};

eval {
    # Sync
    $file1Name = 'stream-sync.pdf';
    open(my $file1, '>', $file1Name) or die "Could not write '".$file1Name."'. Check your file system permissions.";
    $pdfReactor->convertAsBinary($config, $file1);

    # Async
    $connectionSettings = {};
    $documentId = $pdfReactor->convertAsync($config, $connectionSettings);
    $progress;

    do {
        sleep(0.5);
        $progress = $pdfReactor->getProgress($documentId, $connectionSettings);
    } while ($progress->{finished} == 0);

    $file2Name = 'stream-async.pdf';
    open(my $file2, '>', $file2Name) or die "Could not write '".$file2Name."'. Check your file system permissions.";
    $pdfReactor->getDocumentAsBinary($documentId, $file2, $connectionSettings);

    print "Content-Type: text/html\n\n";
    print "<h1>2 files successfully written: '".$file1Name."' and '".$file2Name."'. Please check your file system.</h1>";
} || do {
    my $e = $@;

    # Not successful, print error and log
    print "Content-type: text/html\n\n";
    print "<h1>Error During Rendering</h1>";

    if ($e->isa("PDFreactor::PDFreactorWebserviceException")) {
        print "<h2>".$e->{message}."</h2>";
    } else {
        print "<h2>".$e."</h2>";
    }
};
