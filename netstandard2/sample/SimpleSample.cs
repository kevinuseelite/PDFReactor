using System;
using System.ComponentModel.DataAnnotations;
using System.IO;
using RealObjects.PDFreactor.Webservice.Client;

namespace netstandard2
{
    class SimpleSample
    {
        /**
         * The classes Stream.cs and Async.cs also include Main
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
            RealObjects.PDFreactor.Webservice.Client.Configuration config = new RealObjects.PDFreactor.Webservice.Client.Configuration();

            // Specify the input document
            config.Document = contentURI;

            // Set an appropriate log level
            config.LogLevel = LogLevel.WARN;

            // Sets the title of the created PDF
            config.Title = "Demonstration of PDFreactor .NET Core API";

            // Sets the author of the created PDF
            config.Author = "Myself";

            // Set some viewer preferences
            config.ViewerPreferences.Add(ViewerPreferences.FIT_WINDOW);
            config.ViewerPreferences.Add(ViewerPreferences.PAGE_MODE_USE_THUMBS);
            
            // Add user style sheets
            config.UserStyleSheets.Add(new Resource {
                Content = "@page {" +
                              "@top-center {" +
                                  "content: 'PDFreactor .NET API demonstration';" +
                              "}" +
                              " @bottom-center {" +
                                  "content: \"Created on " + day + "/" + month + "/" + year + " " + time + "\";" +
                              "}" +
                          "}"
            });
            config.UserStyleSheets.Add(new Resource {
                Uri = "../../resources/common.css"
            });

            try
            {
                Result result = pdfreactor.Convert(config);
                byte[] pdf = result.Document;
                File.WriteAllBytes("simple.pdf", pdf);
            } catch (PDFreactorWebserviceException e) {
                Console.WriteLine("An Error Has Occurred");
                Console.WriteLine(e.Message);
            }
        }
    }
}
