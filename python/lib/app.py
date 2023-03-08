import os
import sys
sys.path.append(os.path
    .abspath(os.path.join(os.path.dirname( __file__ ), '../lib/')))
from PDFreactor import *

pdfReactor = PDFreactor()

config = {
    'document': "<html><body><h1>Hello World</h1></body><br><br><br>"
    "<br></html><body>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is my test body</body> " ,
    'title': "Hello World sample",
    'viewerPreferences': [
        PDFreactor.ViewerPreferences.FIT_WINDOW,
        PDFreactor.ViewerPreferences.PAGE_MODE_USE_THUMBS
    ],
    'userStyleSheets': [
        {
            'content': "body {"\
                           "margin: 1cm;"\
                       "}"
        }
    ]
}
# The resulting PDF
result = None

try: 
    # Render document and save result
    result = pdfReactor.convertAsBinary(config)
    with open("output.pdf", "wb") as f:
        f.write(result)
        
except Exception as e:
    # Not successful, print error and log
    print("Content-type: text/html\n\n")
    print("<h1>An Error Has Occurred</h1>")
    print("<h2>" + str(e) + "</h2>")
    
# Check if successful
if result != None:
    if sys.platform == "win32":
        import msvcrt
        msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)

    # Set the correct header for PDF output and echo PDF content
    print("Content-Type: application/pdf\n")

    # Check Python version
    if sys.version_info.major == 2:
        print(result)
    else:
        sys.stdout.flush()
        sys.stdout.buffer.write(result)

