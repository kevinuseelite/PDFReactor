import java.io.FileOutputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.realobjects.pdfreactor.webservice.client.Configuration;
import com.realobjects.pdfreactor.webservice.client.Configuration.LogLevel;
import com.realobjects.pdfreactor.webservice.client.Configuration.Resource;
import com.realobjects.pdfreactor.webservice.client.Configuration.ViewerPreferences;
import com.realobjects.pdfreactor.webservice.client.PDFreactor;
import com.realobjects.pdfreactor.webservice.client.PDFreactorWebserviceException;
import com.realobjects.pdfreactor.webservice.client.Result;

/**
 * A sample demonstrating the simple integration of PDFreactor into Java applications.
 */
public class SimpleSample {
    
    public static void main(String[] args) {
        
        DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        Date date = new Date();
        String timeStamp = dateFormat.format(date);
        
        // Create new PDFreactor instance
        PDFreactor pdfReactor = new PDFreactor("https://cloud.pdfreactor.com/service/rest");
        
        // Create a new configuration object
        Configuration config = new Configuration()
            
            // Specify the input document for Windows systems (adapt path if necessary)
            .setDocument("file:///C:/Program%20Files/PDFreactor/clients/resources/contentJava.html")
            
            // Specify the input document for Mac systems (adapt path if necessary)
            //.setDocument("file:///Applications/PDFreactor/clients/resources/contentJava.html")
            
            // Specify the input document for Linux systems (adapt path if necessary)
            //.setDocument("file:///opt/PDFreactor/clients/resources/contentJava.html")
            
            // Set an appropriate log level
            .setLogLevel(LogLevel.WARN)
            // Sets the title of the created PDF
            .setTitle("Demonstration of PDFreactor Java API")
            // Sets the author of the created PDF
            .setAuthor("Myself")
            // Set some viewer preferences
            .setViewerPreferences(
                ViewerPreferences.FIT_WINDOW,
                ViewerPreferences.PAGE_MODE_USE_THUMBS)
            // Add user style sheets
            .setUserStyleSheets(
                new Resource().setContent("@page {" +
                                              "@top-center {" +
                                                  "content: 'PDFreactor Java API demonstration';" +
                                              "}" +
                                              " @bottom-center {" +
                                                  "content: \"Created on " + timeStamp + "\";" +
                                              "}" +
                                          "}"),
                new Resource().setUri("common.css"));
            
        try {
            // Convert document
            Result result = pdfReactor.convert(config);
            
            if (result != null) {
                byte[] pdf = result.getDocument();
                
                // Save the pdf at the desired location
                try (FileOutputStream fos = new FileOutputStream("simple.pdf")) {
                    fos.write(pdf);
                }
            }
            
            System.out.println("Files successfully written: 'simple.pdf'. Please check your file system.");
        } catch (PDFreactorWebserviceException exception) {
            System.err.println(exception.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
