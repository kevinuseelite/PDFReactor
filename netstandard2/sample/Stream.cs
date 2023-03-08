using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using RealObjects.PDFreactor.Webservice.Client;

namespace netstandard2
{
	class Stream
	{
        /**
         * The classes Async.cs and SimpleSample.cs also include Main
         * methods. To run this sample in Visual Studio, you may want 
         * to rename the Main methods in these classes.
         */ 
		static void Main(string[] args)
        {
			// Create new PDFreactor instance
			// PDFreactor pdfReactor = new PDFreactor("http://yourServer:9423/service/rest");
			PDFreactor pdfreactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");

			// URI to load document content
			string contentURI = "file:///C:/Program%20Files/PDFreactor/clients/resources/contentDotnet.html";

			DateTime date = System.DateTime.Now;
			String day = date.ToString("MM");
			String month = date.ToString("dd");
			String year = date.ToString("yyyy");
			String time = date.ToString("hh:mm:ss");

            // Create a new configuration object
            Configuration config = new Configuration
            {
                // Specify the input document
                Document = contentURI,

                // Set an appropriate log level
                LogLevel = LogLevel.WARN,

                // Sets the title of the created PDF
                Title = "Demonstration of PDFreactor .NET API",

                // Sets the author of the created PDF
                Author = "Myself",

                // Set some viewer preferences
                ViewerPreferences = new List<ViewerPreferences>
                {
                    ViewerPreferences.FIT_WINDOW,
                    ViewerPreferences.PAGE_MODE_USE_THUMBS
                },

                // Add user style sheets
                UserStyleSheets = new List<Resource>
                {
                    new Resource
                    {
                        Content = "@page {" +
                                    "@top-center {" +
                                        "content: 'PDFreactor .NET API demonstration';" +
                                    "}" +
                                    " @bottom-center {" +
                                        "content: \"Created on " + day + "/" + month + "/" + year + " " + time + "\";" +
                                    "}" +
                                "}"
                    },
                    new Resource
                    {
                        Uri = "../../resources/common.css"
                    }
                }
            };

            try
            {
                // Sync
                FileStream file1 = File.Create("stream-sync.pdf");
                pdfreactor.ConvertAsBinary(config, file1);

                // Async
                ConnectionSettings connectionSettings = new ConnectionSettings();
                String documentId = pdfreactor.ConvertAsync(config, connectionSettings);
                Progress progress;

                do
                {
                    Thread.Sleep(500);
                    progress = pdfreactor.GetProgress(documentId, connectionSettings);
                }
                while (!progress.Finished);

                FileStream file2 = File.Create("stream-async.pdf");
                pdfreactor.GetDocumentAsBinary(documentId, file2, connectionSettings);

                Console.Write("2 files successfully written: 'stream-sync.pdf' and 'stream-async.pdf'. Please check your file system.");
            }
            catch (PDFreactorWebserviceException e)
            {
                Console.WriteLine("An Error Has Occurred");
                Console.WriteLine(e.Message);
            }
        }

	}
}
