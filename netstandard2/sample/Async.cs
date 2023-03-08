using RealObjects.PDFreactor.Webservice.Client;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;

namespace netstandard2
{
    class Async
    {
        /**
         * The classes SimpleSample.cs and Stream.cs also include Main
         * methods. To run this sample in Visual Studio, you may want 
         * to rename the Main methods in these classes.
         */ 
        static void Main(string[] args)
        {
            // Create new PDFreactor instance
            // PDFreactor pdfReactor = new PDFreactor("http://yourServer:9423/service/rest");
            PDFreactor pdfReactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");

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
                // Connection settings are required when using the PDFreactor Cloud Service or if the PDFreactor Web Service is behind a load balancer
                ConnectionSettings connectionSettings = new ConnectionSettings();
                // Start document conversion
                String documentId = pdfReactor.ConvertAsync(config, connectionSettings);
                Progress progress;

                do
                {
                    // Poll conversion progress
                    Thread.Sleep(500);
                    progress = pdfReactor.GetProgress(documentId, connectionSettings);
                } while (!progress.Finished);

                Result result = pdfReactor.GetDocument(documentId, connectionSettings);
                byte[] pdf = result.Document;
                File.WriteAllBytes("async.pdf", pdf);
            }
            catch (Exception e)
            {
                // catch PDFreactorWebserviceException in production instead
                Console.WriteLine("An Error Has Occurred");
                Console.WriteLine(e.Message);
            }
        }

    }
}
