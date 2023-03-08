#!/usr/bin/env python

import datetime
import sys
import json
if sys.version_info[0] == 2:
    from urllib2 import HTTPError
    from urllib2 import URLError
else:
    from urllib.error import HTTPError
    from urllib.error import URLError
from argparse import ArgumentParser
from argparse import RawTextHelpFormatter


# helper methods

def isUrl(u):
    try:
        from urlparse import urlparse
        result = urlparse(u)
        if result.scheme:
            return True
    except:
        return False
    return False
def isFile(f):
    try:
        import os.path
        return os.path.isfile(f)
    except:
        return False
    return False
def log(msg):
    if quiet == None:
        print(msg)
def writeOutputFiles(doc, docNumber, pageNumber, extension):
    document = binascii.a2b_base64(doc)
    outputName = ""
    if outputFile == None:
        if (absPath != ""):
            outputName = absPath + getPageSuffix(pageNumber) + "." + extension
        else:
            outputName = "out" + getPageSuffix(pageNumber) + "." + extension
            import os.path
            i = 1
            while (os.path.isfile(outputName)):
                outputName = "out" + str(i) + getPageSuffix(pageNumber) + "." + extension
                i = i+1
    else:
        outputName = outputFile
        if (docNumber > 0 or pageNumber > 0):
            lastDot = outputFile.rfind(".")
            if (lastDot != -1):
                tmpSplit = outputFile.rsplit(".")
                outputName = tmpSplit[0]
                if (docNumber > 0):
                    outputName += str(docNumber)
                outputName += getPageSuffix(pageNumber) + "." + tmpSplit[1]
            else:
                outputName = outputFile + getPageSuffix(pageNumber) + "." + extension
    f = open(outputName, 'wb')
    f.write(document)
    f.close()
    return docNumber+1
def getFileExtesionForType(type):
    return type.split('_')[0].lower()
def getPageSuffix(pageNumber):
    if pageNumber <= 0:
        return ''
    return "-page" + str(pageNumber)

errrorStr = "An error has occured." 

try:
    parser = ArgumentParser()
    parser.formatter_class=RawTextHelpFormatter
    configuration = {}

    '''Member'''
    outputType = "pdf"
    '''Client arguments'''
    parser.add_argument("-i", "--document", dest="url", nargs="+", help="The file to render as a PDF document (as an URL, path incl. wildcards or file URI). ")
    parser.add_argument("-o", "--output", dest="outputFile", help="The output file to write the document to.\nOptional argument.\nIf no argument is passed, the output file name is based on the input file name.")
    parser.add_argument("-s", "--serverUrl", dest="serverUrl", help="The URL of the PDFreactor Web Service.")

    parser.add_argument("-a", "--assetPackage", dest="assetPackage", help="Treats the input document as an asset package.", action="count")
    parser.add_argument("-c", "--css", dest="css", nargs="+", help="Adds one or more user style sheets to the document. The style sheets can be CSS content, absolute URLs or file paths.")
    parser.add_argument("-j", "--javaScript", dest="javaScript", nargs="+", help="Enables JavaScript processing and adds one or more user scripts to the document. The scripts can be JavaScript content, absolute URLs or file paths.")
    parser.add_argument("-x", "--xslt", dest="javaScript", nargs="+", help="Adds one or more XSL transformations to the document. The transformations can be XSLT content, absolute URLs or file paths.")
    parser.add_argument("-d", "--debug", dest="debug", action="count", help="Converts the document in debug mode.")
    parser.add_argument("-I", "--inspectable", dest="inspectable", nargs="+", help="Makes the converted PDF inspectable with the PDFreactor Development Tools.")
    parser.add_argument("-v", "--verbose", dest="verbose", action="count", help="Enables verbose log output.")
    parser.add_argument("-C", "--config", dest="config", help="The PDFreactor configuration as a JSON string or a path to a JSON file. If set, this configuration will be used as a base, further modified by the additional command line options.")
    parser.add_argument("-q", "--quiet", dest="quiet", action="count", help="Disables log output.")
    parser.add_argument("-V", "--version", dest="version", action="count", help="Prints the version of the PDFreactor Web Service and the CLI version.")
    ''' Auto-generated arguments'''
    parser.add_argument("--addAttachments", dest="addAttachments", help="Enables or disables attachments specified in style sheets.\n\n", action="store_true")
    parser.add_argument("--addBookmarks", dest="addBookmarks", help="Deprecated as of PDFreactor 11.\n\n", action="store_true")
    parser.add_argument("--addComments", dest="addComments", help="Enables or disables comments in the PDF document.\n\n", action="store_true")
    parser.add_argument("--addLinks", dest="addLinks", help="Deprecated as of PDFreactor 11.\n\n", action="store_true")
    parser.add_argument("--addOverprint", dest="addOverprint", help="Enables or disables overprinting.\n\n", action="store_true")
    parser.add_argument("--addPreviewImages", dest="addPreviewImages", help="Enables or disables embedding of image previews per page in the PDF document.\n\n", action="store_true")
    parser.add_argument("--addTags", dest="addTags", help="Enables or disables tagging of the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowAnnotations", dest="allowAnnotations", help="Enables or disables the 'annotations' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowAssembly", dest="allowAssembly", help="Enables or disables the 'assembly' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowCopy", dest="allowCopy", help="Enables or disables the 'copy' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowDegradedPrinting", dest="allowDegradedPrinting", help="Enables or disables the 'degraded printing' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowFillIn", dest="allowFillIn", help="Enables or disables the 'fill in' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowModifyContents", dest="allowModifyContents", help="Enables or disables the 'modify contents' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowPrinting", dest="allowPrinting", help="Enables or disables the 'printing' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--allowScreenReaders", dest="allowScreenReaders", help="Enables or disables the 'screen readers' restriction in the PDF document.\n\n", action="store_true")
    parser.add_argument("--appendLog", dest="appendLog", help="Specifies whether or not the log data should be added to the PDF document.\n\n", action="store_true")
    parser.add_argument("--author", dest="author", help="Sets the value of the author field of the PDF document.\n\n", metavar="AUTHOR")
    parser.add_argument("--baseURL", dest="baseURL", help="Deprecated as of PDFreactor 11.\n\n", metavar="BASE_URL")
    parser.add_argument("--baseUrl", dest="baseUrl", help="Sets the base URL of the document.\n\n", metavar="BASE_URL")
    parser.add_argument("--cleanupTool", dest="cleanupTool", help="Sets the cleanup tool to use for documents with unparsable content.\n\n", metavar="CLEANUP_TOOL", choices=["CYBERNEKO", "JTIDY", "NONE", "TAGSOUP"], type=str.upper)
    parser.add_argument("--conformance", dest="conformance", help="Sets the conformance of the PDF.\n\n", metavar="CONFORMANCE", choices=["PDF", "PDFA1A", "PDFA1A_PDFUA1", "PDFA1B", "PDFA2A", "PDFA2A_PDFUA1", "PDFA2B", "PDFA2U", "PDFA3A", "PDFA3A_PDFUA1", "PDFA3B", "PDFA3U", "PDFUA1", "PDFX1A_2001", "PDFX1A_2003", "PDFX3_2002", "PDFX3_2003", "PDFX4", "PDFX4P"], type=str.upper)
    parser.add_argument("--conversionName", dest="conversionName", help="Sets a name for the conversion.\n\n", metavar="CONVERSION_NAME")
    parser.add_argument("--conversionTimeout", dest="conversionTimeout", help="Sets a timeout in seconds for the whole document conversion.\n\n", metavar="CONVERSION_TIMEOUT")
    parser.add_argument("--creator", dest="creator", help="Sets the value of creator field of the PDF document.\n\n", metavar="CREATOR")
    parser.add_argument("--defaultColorSpace", dest="defaultColorSpace", help="Deprecated as of PDFreactor 10.\n\n", metavar="DEFAULT_COLOR_SPACE", choices=["CMYK", "RGB"], type=str.upper)
    parser.add_argument("--disableBookmarks", dest="disableBookmarks", help="Disables bookmarks in the PDF document.\n\n", action="store_true")
    parser.add_argument("--disableFontEmbedding", dest="disableFontEmbedding", help="Sets whether fonts will not be embedded into the resulting PDF.\n\n", action="store_true")
    parser.add_argument("--disableLinks", dest="disableLinks", help="Disables links in the PDF document.\n\n", action="store_true")
    parser.add_argument("--documentDefaultLanguage", dest="documentDefaultLanguage", help="Sets the language used for documents having no explicit language attribute set.\n\n", metavar="DOCUMENT_DEFAULT_LANGUAGE")
    parser.add_argument("--documentType", dest="documentType", help="Sets the document type.\n\n", metavar="DOCUMENT_TYPE", choices=["AUTODETECT", "HTML5", "XHTML", "XML"], type=str.upper)
    parser.add_argument("--enableDebugMode", dest="enableDebugMode", help="Deprecated as of PDFreactor 10.\n\n", action="store_true")
    parser.add_argument("--encoding", dest="encoding", help="Sets the encoding of the document.\n\n", metavar="ENCODING")
    parser.add_argument("--encryption", dest="encryption", help="Sets the encryption.\n\n", metavar="ENCRYPTION", choices=["NONE", "TYPE_128", "TYPE_40"], type=str.upper)
    parser.add_argument("--errorPolicies", dest="errorPolicies", help="Specifies error policies that will be used for the conversion.\n\n", nargs="+", metavar="ERROR_POLICIES", choices=["CONFORMANCE_VALIDATION_UNAVAILABLE", "LICENSE", "MISSING_RESOURCE", "UNCAUGHT_JAVASCRIPT_EXCEPTION"], type=str.upper)
    parser.add_argument("--fontFallback", dest="fontFallback", help="Sets a list of fallback font families used for character substitution.\n\n", nargs="+", metavar="FONT_FALLBACK")
    parser.add_argument("--forceGrayscaleImage", dest="forceGrayscaleImage", help="If the output format is an image format, this setting controls whether a\ngrayscale image should be returned.\n\n", action="store_true")
    parser.add_argument("--fullCompression", dest="fullCompression", help="Enables or disables full compression of the PDF document.\n\n", action="store_true")
    parser.add_argument("--httpsMode", dest="httpsMode", help="Sets the HTTPS mode.\n\n", metavar="HTTPS_MODE", choices=["LENIENT", "STRICT"], type=str.upper)
    parser.add_argument("--ignoreAlpha", dest="ignoreAlpha", help="Sets whether the alpha value of CSS RGBA colors is ignored.\n\n", action="store_true")
    parser.add_argument("--javaScriptMode", dest="javaScriptMode", help="Deprecated as of PDFreactor 10.\n\n", metavar="JAVA_SCRIPT_MODE", choices=["DISABLED", "ENABLED", "ENABLED_NO_LAYOUT", "ENABLED_REAL_TIME", "ENABLED_TIME_LAPSE"], type=str.upper)
    parser.add_argument("--keywords", dest="keywords", help="Sets the value of the keywords field of the PDF document.\n\n", metavar="KEYWORDS")
    parser.add_argument("--licenseKey", dest="licenseKey", help="Sets the license key either as content or URL.\n\n", metavar="LICENSE_KEY")
    parser.add_argument("--logLevel", dest="logLevel", help="Sets the log level for the conversion log.\n\n", metavar="LOG_LEVEL", choices=["DEBUG", "FATAL", "INFO", "NONE", "PERFORMANCE", "WARN"], type=str.upper)
    parser.add_argument("--logMaxLines", dest="logMaxLines", help="Sets the maximum amount of log entries that \nwill be retained by the PDFreactor logs.\n\n", metavar="LOG_MAX_LINES")
    parser.add_argument("--mediaTypes", dest="mediaTypes", help="Sets the media types that are used to resolve CSS3 media queries.\n\n", nargs="+", metavar="MEDIA_TYPES")
    parser.add_argument("--mergeByteArray", dest="mergeByteArray", help="Deprecated as of PDFreactor 9.\n\n")
    parser.add_argument("--mergeByteArrays", dest="mergeByteArrays", help="Deprecated as of PDFreactor 9.\n\n")
    parser.add_argument("--mergeMode", dest="mergeMode", help="Sets the merge mode.\n\n", metavar="MERGE_MODE", choices=["APPEND", "ARRANGE", "OVERLAY", "OVERLAY_BELOW", "PREPEND"], type=str.upper)
    parser.add_argument("--mergeURL", dest="mergeURL", help="Deprecated as of PDFreactor 9.\n\n", metavar="MERGE_URL")
    parser.add_argument("--mergeURLs", dest="mergeURLs", help="Deprecated as of PDFreactor 9.\n\n", nargs="+", metavar="MERGE_URLS")
    parser.add_argument("--overlayRepeat", dest="overlayRepeat", help="If one of the documents of an overlay process is shorter than the other, this method \nallows repeating either its last page or all of its pages in order to overlay all pages of \nthe longer document.\n\n", metavar="OVERLAY_REPEAT", choices=["ALL_PAGES", "LAST_PAGE", "NONE", "TRIM"], type=str.upper)
    parser.add_argument("--ownerPassword", dest="ownerPassword", help="Sets the owner password of the PDF document.\n\n", metavar="OWNER_PASSWORD")
    parser.add_argument("--pageOrder", dest="pageOrder", help="Sets the page order of the direct result of the conversion.\n\n", metavar="PAGE_ORDER")
    parser.add_argument("--pixelsPerInch", dest="pixelsPerInch", help="Sets the pixels per inch.\n\n", metavar="PIXELS_PER_INCH")
    parser.add_argument("--pixelsPerInchShrinkToFit", dest="pixelsPerInchShrinkToFit", help="Whether the pixels per inch should be adapted automatically to avoid content exceeding pages.\n\n", action="store_true")
    parser.add_argument("--postTransformationDocumentType", dest="postTransformationDocumentType", help="Sets the document type after the XSL-Transformations have been applied.\n\n", metavar="POST_TRANSFORMATION_DOCUMENT_TYPE", choices=["AUTODETECT", "HTML5", "XHTML", "XML"], type=str.upper)
    parser.add_argument("--printDialogPrompt", dest="printDialogPrompt", help="Enables or disables a print dialog to be shown upon opening\nthe generated PDF document by a PDF viewer.\n\n", action="store_true")
    parser.add_argument("--processingPreferences", dest="processingPreferences", help="Preferences that influence the conversion process without changing \nthe output.\n\n", nargs="+", metavar="PROCESSING_PREFERENCES", choices=["SAVE_MEMORY_IMAGES"], type=str.upper)
    parser.add_argument("--requestPriority", dest="requestPriority", help="Specifies the priority of the conversion request.\n\n", metavar="REQUEST_PRIORITY")
    parser.add_argument("--resourceConnectTimeout", dest="resourceConnectTimeout", help="Sets a timeout in milliseconds for connecting to resources, such as HTTP requests to \nstyle sheets, images etc.\n\n", metavar="RESOURCE_CONNECT_TIMEOUT")
    parser.add_argument("--resourceReadTimeout", dest="resourceReadTimeout", help="Sets a timeout in milliseconds for reading resources, such as HTTP requests to \nstyle sheets, images etc.\n\n", metavar="RESOURCE_READ_TIMEOUT")
    parser.add_argument("--resourceRequestTimeout", dest="resourceRequestTimeout", help="Deprecated as of PDFreactor 10.\n\n", metavar="RESOURCE_REQUEST_TIMEOUT")
    parser.add_argument("--subject", dest="subject", help="Sets the value of the subject field of the PDF document.\n\n", metavar="SUBJECT")
    parser.add_argument("--throwLicenseExceptions", dest="throwLicenseExceptions", help="Deprecated as of PDFreactor 9.\n\n", action="store_true")
    parser.add_argument("--title", dest="title", help="Sets the value of the title field of the PDF document.\n\n", metavar="TITLE")
    parser.add_argument("--userPassword", dest="userPassword", help="Sets the user password of the PDF document.\n\n", metavar="USER_PASSWORD")
    parser.add_argument("--validateConformance", dest="validateConformance", help="Enables PDFreactor to validate the generated PDF against the \nspecified via .\n\n", action="store_true")
    parser.add_argument("--viewerPreferences", dest="viewerPreferences", help="Sets the page layout and page mode preferences of the PDF.\n\n", nargs="+", metavar="VIEWER_PREFERENCES", choices=["CENTER_WINDOW", "DIRECTION_L2R", "DIRECTION_R2L", "DISPLAY_DOC_TITLE", "DUPLEX_FLIP_LONG_EDGE", "DUPLEX_FLIP_SHORT_EDGE", "DUPLEX_SIMPLEX", "FIT_WINDOW", "HIDE_MENUBAR", "HIDE_TOOLBAR", "HIDE_WINDOW_UI", "NON_FULLSCREEN_PAGE_MODE_USE_NONE", "NON_FULLSCREEN_PAGE_MODE_USE_OC", "NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES", "NON_FULLSCREEN_PAGE_MODE_USE_THUMBS", "PAGE_LAYOUT_ONE_COLUMN", "PAGE_LAYOUT_SINGLE_PAGE", "PAGE_LAYOUT_TWO_COLUMN_LEFT", "PAGE_LAYOUT_TWO_COLUMN_RIGHT", "PAGE_LAYOUT_TWO_PAGE_LEFT", "PAGE_LAYOUT_TWO_PAGE_RIGHT", "PAGE_MODE_FULLSCREEN", "PAGE_MODE_USE_ATTACHMENTS", "PAGE_MODE_USE_NONE", "PAGE_MODE_USE_OC", "PAGE_MODE_USE_OUTLINES", "PAGE_MODE_USE_THUMBS", "PICKTRAYBYPDFSIZE_FALSE", "PICKTRAYBYPDFSIZE_TRUE", "PRINTSCALING_APPDEFAULT", "PRINTSCALING_NONE"], type=str.upper)
    parser.add_argument("--xsltMode", dest="xsltMode", help="Enables or disables XSLT transformations.\n\n", action="store_true")

    '''Parse arguments'''
    args = parser.parse_args()

    '''Read argument values'''
    if hasattr(args, 'config') and args.config != None:
        parsedConfig = None
        try:
            if isFile(args.config):
                f = open(args.config, 'r')
                parsedConfig = json.loads(f.read())
                f.close()
            else:
                parsedConfig = json.loads(args.config)
        except:
            parsedConfig = None
        if parsedConfig != None:
            configuration = parsedConfig
    if hasattr(args, 'addAttachments') and args.addAttachments != None:
        defaultVal = False
        if defaultVal != args.addAttachments:
            configuration["addAttachments"] = args.addAttachments
    if hasattr(args, 'addBookmarks') and args.addBookmarks != None:
        defaultVal = False
        if defaultVal != args.addBookmarks:
            configuration["addBookmarks"] = args.addBookmarks
    if hasattr(args, 'addComments') and args.addComments != None:
        defaultVal = False
        if defaultVal != args.addComments:
            configuration["addComments"] = args.addComments
    if hasattr(args, 'addLinks') and args.addLinks != None:
        defaultVal = False
        if defaultVal != args.addLinks:
            configuration["addLinks"] = args.addLinks
    if hasattr(args, 'addOverprint') and args.addOverprint != None:
        defaultVal = False
        if defaultVal != args.addOverprint:
            configuration["addOverprint"] = args.addOverprint
    if hasattr(args, 'addPreviewImages') and args.addPreviewImages != None:
        defaultVal = False
        if defaultVal != args.addPreviewImages:
            configuration["addPreviewImages"] = args.addPreviewImages
    if hasattr(args, 'addTags') and args.addTags != None:
        defaultVal = False
        if defaultVal != args.addTags:
            configuration["addTags"] = args.addTags
    if hasattr(args, 'allowAnnotations') and args.allowAnnotations != None:
        defaultVal = False
        if defaultVal != args.allowAnnotations:
            configuration["allowAnnotations"] = args.allowAnnotations
    if hasattr(args, 'allowAssembly') and args.allowAssembly != None:
        defaultVal = False
        if defaultVal != args.allowAssembly:
            configuration["allowAssembly"] = args.allowAssembly
    if hasattr(args, 'allowCopy') and args.allowCopy != None:
        defaultVal = False
        if defaultVal != args.allowCopy:
            configuration["allowCopy"] = args.allowCopy
    if hasattr(args, 'allowDegradedPrinting') and args.allowDegradedPrinting != None:
        defaultVal = False
        if defaultVal != args.allowDegradedPrinting:
            configuration["allowDegradedPrinting"] = args.allowDegradedPrinting
    if hasattr(args, 'allowFillIn') and args.allowFillIn != None:
        defaultVal = False
        if defaultVal != args.allowFillIn:
            configuration["allowFillIn"] = args.allowFillIn
    if hasattr(args, 'allowModifyContents') and args.allowModifyContents != None:
        defaultVal = False
        if defaultVal != args.allowModifyContents:
            configuration["allowModifyContents"] = args.allowModifyContents
    if hasattr(args, 'allowPrinting') and args.allowPrinting != None:
        defaultVal = False
        if defaultVal != args.allowPrinting:
            configuration["allowPrinting"] = args.allowPrinting
    if hasattr(args, 'allowScreenReaders') and args.allowScreenReaders != None:
        defaultVal = False
        if defaultVal != args.allowScreenReaders:
            configuration["allowScreenReaders"] = args.allowScreenReaders
    if hasattr(args, 'appendLog') and args.appendLog != None:
        defaultVal = False
        if defaultVal != args.appendLog:
            configuration["appendLog"] = args.appendLog
    if hasattr(args, 'author') and args.author != None:
        configuration["author"] = args.author
    if hasattr(args, 'baseURL') and args.baseURL != None:
        configuration["baseURL"] = args.baseURL
    if hasattr(args, 'baseUrl') and args.baseUrl != None:
        configuration["baseUrl"] = args.baseUrl
    if hasattr(args, 'cleanupTool') and args.cleanupTool != None:
        configuration["cleanupTool"] = args.cleanupTool
    if hasattr(args, 'conformance') and args.conformance != None:
        configuration["conformance"] = args.conformance
    if hasattr(args, 'conversionName') and args.conversionName != None:
        configuration["conversionName"] = args.conversionName
    if hasattr(args, 'conversionTimeout') and args.conversionTimeout != None:
        configuration["conversionTimeout"] = args.conversionTimeout
    if hasattr(args, 'creator') and args.creator != None:
        configuration["creator"] = args.creator
    if hasattr(args, 'defaultColorSpace') and args.defaultColorSpace != None:
        configuration["defaultColorSpace"] = args.defaultColorSpace
    if hasattr(args, 'disableBookmarks') and args.disableBookmarks != None:
        defaultVal = False
        if defaultVal != args.disableBookmarks:
            configuration["disableBookmarks"] = args.disableBookmarks
    if hasattr(args, 'disableFontEmbedding') and args.disableFontEmbedding != None:
        defaultVal = False
        if defaultVal != args.disableFontEmbedding:
            configuration["disableFontEmbedding"] = args.disableFontEmbedding
    if hasattr(args, 'disableLinks') and args.disableLinks != None:
        defaultVal = False
        if defaultVal != args.disableLinks:
            configuration["disableLinks"] = args.disableLinks
    if hasattr(args, 'documentDefaultLanguage') and args.documentDefaultLanguage != None:
        configuration["documentDefaultLanguage"] = args.documentDefaultLanguage
    if hasattr(args, 'documentType') and args.documentType != None:
        configuration["documentType"] = args.documentType
    if hasattr(args, 'enableDebugMode') and args.enableDebugMode != None:
        defaultVal = False
        if defaultVal != args.enableDebugMode:
            configuration["enableDebugMode"] = args.enableDebugMode
    if hasattr(args, 'encoding') and args.encoding != None:
        configuration["encoding"] = args.encoding
    if hasattr(args, 'encryption') and args.encryption != None:
        configuration["encryption"] = args.encryption
    if hasattr(args, 'errorPolicies') and args.errorPolicies != None:
        configuration["errorPolicies"] = args.errorPolicies
    if hasattr(args, 'fontFallback') and args.fontFallback != None:
        configuration["fontFallback"] = args.fontFallback
    if hasattr(args, 'forceGrayscaleImage') and args.forceGrayscaleImage != None:
        defaultVal = False
        if defaultVal != args.forceGrayscaleImage:
            configuration["forceGrayscaleImage"] = args.forceGrayscaleImage
    if hasattr(args, 'fullCompression') and args.fullCompression != None:
        defaultVal = False
        if defaultVal != args.fullCompression:
            configuration["fullCompression"] = args.fullCompression
    if hasattr(args, 'httpsMode') and args.httpsMode != None:
        configuration["httpsMode"] = args.httpsMode
    if hasattr(args, 'ignoreAlpha') and args.ignoreAlpha != None:
        defaultVal = False
        if defaultVal != args.ignoreAlpha:
            configuration["ignoreAlpha"] = args.ignoreAlpha
    if hasattr(args, 'javaScriptMode') and args.javaScriptMode != None:
        configuration["javaScriptMode"] = args.javaScriptMode
    if hasattr(args, 'keywords') and args.keywords != None:
        configuration["keywords"] = args.keywords
    if hasattr(args, 'licenseKey') and args.licenseKey != None:
        configuration["licenseKey"] = args.licenseKey
    if hasattr(args, 'logLevel') and args.logLevel != None:
        configuration["logLevel"] = args.logLevel
    if hasattr(args, 'logMaxLines') and args.logMaxLines != None:
        configuration["logMaxLines"] = args.logMaxLines
    if hasattr(args, 'mediaTypes') and args.mediaTypes != None:
        configuration["mediaTypes"] = args.mediaTypes
    if hasattr(args, 'mergeByteArray') and args.mergeByteArray != None:
        configuration["mergeByteArray"] = args.mergeByteArray
    if hasattr(args, 'mergeByteArrays') and args.mergeByteArrays != None:
        configuration["mergeByteArrays"] = args.mergeByteArrays
    if hasattr(args, 'mergeMode') and args.mergeMode != None:
        configuration["mergeMode"] = args.mergeMode
    if hasattr(args, 'mergeURL') and args.mergeURL != None:
        configuration["mergeURL"] = args.mergeURL
    if hasattr(args, 'mergeURLs') and args.mergeURLs != None:
        configuration["mergeURLs"] = args.mergeURLs
    if hasattr(args, 'overlayRepeat') and args.overlayRepeat != None:
        configuration["overlayRepeat"] = args.overlayRepeat
    if hasattr(args, 'ownerPassword') and args.ownerPassword != None:
        configuration["ownerPassword"] = args.ownerPassword
    if hasattr(args, 'pageOrder') and args.pageOrder != None:
        configuration["pageOrder"] = args.pageOrder
    if hasattr(args, 'pixelsPerInch') and args.pixelsPerInch != None:
        configuration["pixelsPerInch"] = args.pixelsPerInch
    if hasattr(args, 'pixelsPerInchShrinkToFit') and args.pixelsPerInchShrinkToFit != None:
        defaultVal = False
        if defaultVal != args.pixelsPerInchShrinkToFit:
            configuration["pixelsPerInchShrinkToFit"] = args.pixelsPerInchShrinkToFit
    if hasattr(args, 'postTransformationDocumentType') and args.postTransformationDocumentType != None:
        configuration["postTransformationDocumentType"] = args.postTransformationDocumentType
    if hasattr(args, 'printDialogPrompt') and args.printDialogPrompt != None:
        defaultVal = False
        if defaultVal != args.printDialogPrompt:
            configuration["printDialogPrompt"] = args.printDialogPrompt
    if hasattr(args, 'processingPreferences') and args.processingPreferences != None:
        configuration["processingPreferences"] = args.processingPreferences
    if hasattr(args, 'requestPriority') and args.requestPriority != None:
        configuration["requestPriority"] = args.requestPriority
    if hasattr(args, 'resourceConnectTimeout') and args.resourceConnectTimeout != None:
        configuration["resourceConnectTimeout"] = args.resourceConnectTimeout
    if hasattr(args, 'resourceReadTimeout') and args.resourceReadTimeout != None:
        configuration["resourceReadTimeout"] = args.resourceReadTimeout
    if hasattr(args, 'resourceRequestTimeout') and args.resourceRequestTimeout != None:
        configuration["resourceRequestTimeout"] = args.resourceRequestTimeout
    if hasattr(args, 'subject') and args.subject != None:
        configuration["subject"] = args.subject
    if hasattr(args, 'throwLicenseExceptions') and args.throwLicenseExceptions != None:
        defaultVal = False
        if defaultVal != args.throwLicenseExceptions:
            configuration["throwLicenseExceptions"] = args.throwLicenseExceptions
    if hasattr(args, 'title') and args.title != None:
        configuration["title"] = args.title
    if hasattr(args, 'userPassword') and args.userPassword != None:
        configuration["userPassword"] = args.userPassword
    if hasattr(args, 'validateConformance') and args.validateConformance != None:
        defaultVal = False
        if defaultVal != args.validateConformance:
            configuration["validateConformance"] = args.validateConformance
    if hasattr(args, 'viewerPreferences') and args.viewerPreferences != None:
        configuration["viewerPreferences"] = args.viewerPreferences
    if hasattr(args, 'xsltMode') and args.xsltMode != None:
        defaultVal = False
        if defaultVal != args.xsltMode:
            configuration["xsltMode"] = args.xsltMode
    '''Read additional values'''
    if hasattr(args, 'css') and args.css != None:
        for css in args.css:
            if "userStyleSheets" not in configuration:
                configuration["userStyleSheets"] = []
            if isUrl(css):
                configuration["userStyleSheets"].append({ "uri": css })
            elif isFile(css):
                f = open(css, 'r')
                configuration["userStyleSheets"].append({ "content": f.read()})
                f.close()
            else:
                configuration["userStyleSheets"].append({ "content": css})
    if hasattr(args, 'javaScript') and args.javaScript != None:
        if "javaScriptSettings" not in configuration:
            configuration["javaScriptSettings"] = {}
        configuration["javaScriptSettings"]["enabled"] = True
        for script in args.javaScript:
            if "userScripts" not in configuration:
                configuration["userScripts"] = []
            if isUrl(script):
                configuration["userScripts"].append({ "uri": script })
            elif isFile(script):
                f = open(script, 'r')
                configuration["userScripts"].append({ "content": f.read()})
                f.close()
            else:
                configuration["userScripts"].append({ "content": script})
    if hasattr(args, 'xslt') and args.css != None:
        for xslt in args.xslt:
            if "xsltStyleSheets" not in configuration:
                configuration["xsltStyleSheets"] = []
            if isUrl(xslt):
                configuration["xsltStyleSheets"].append({ "uri": xslt })
            elif isFile(xslt):
                f = open(xslt, 'r')
                configuration["xsltStyleSheets"].append({ "content": f.read()})
                f.close()
            else:
                configuration["xsltStyleSheets"].append({ "content": xslt})
    if hasattr(args, 'inspectable') and args.inspectable != None:
        if "inspectableSettings" not in configuration:
            configuration["inspectableSettings"] = {}
        configuration["inspectableSettings"]["enabled"] = True
    if hasattr(args, 'debug') and args.debug != None:
        if "debugSettings" not in configuration:
            configuration["debugSettings"] = {}
        configuration["debubSettings"]["all"] = True

    '''Read client argument values'''
    configuration["clientVersion"] = 8
    configuration["clientName"] = "CLI"
    url = args.url
    outputFile = args.outputFile
    verbose = args.verbose
    quiet = args.quiet
    serverUrl = args.serverUrl
    version = args.version

    if serverUrl == None:
        serverUrl = "http://localhost:9423/service/rest"

    if serverUrl.endswith("/"):
        serverUrl = serverUrl[0:-1]
    if sys.version_info[0] == 2:
        import urllib2
    else:
        import urllib.request
    clientVersion = "8"
    serverVersion = ""
    try:
        if sys.version_info[0] == 2:
            req = urllib2.Request(serverUrl + '/version.txt')
            response = urllib2.urlopen(req)
        else:
            req = urllib.request.Request(serverUrl + '/version.txt')
            response = urllib.request.urlopen(req)
        res = response.read()
        res = res.decode('utf8')
        serverVersion = res
    except HTTPError as e:
        sys.exit("Error connecting to PDFreactor Web Service at "+serverUrl+". Please make sure the PDFreactor Web Service is installed and running.")
    if version != None:
        log("Client Version: "+clientVersion)
        log("Server Version: "+serverVersion)
    else:
        if url == None:
            log("PDFreactor(R) "+serverVersion+" by RealObjects GmbH (Python CLI version: "+clientVersion+")\n\nUse the \"--help\" argument for more information.")
            #sys.exit('Error: Argument -i/--document is required.')
        if verbose != None and verbose > 0:
            log("Verbose Mode: "+str(verbose))
            if (url != None):
                log("Source URL: "+str(url))
            if (outputFile != None):
                log("Destination: "+outputFile)
            if (serverUrl != None):
                log("Server URL: "+serverUrl)
        if url != None:
            import json
            import binascii
            import sys
            majorVersion = sys.version_info[0]

            if (sys.platform.startswith("win")):
                import glob
                globUrl = glob.glob(url[0])
                if len(globUrl) > 0:
                    tmpUrl = []
                    for globbedUrl in globUrl:
                        tmpUrl.append(globbedUrl)
                    url = tmpUrl

            docNumber = 0

            for path in url:
                absPath = ""
                import os
                if not "://" in path:
                    inputFile = open(path, "r")
                    absPath = os.path.abspath(inputFile.name)
                    if majorVersion == 2:
                        import urlparse, urllib
                        path = urlparse.urljoin('file:', urllib.pathname2url(absPath))
                    else:
                        from urllib.parse import urljoin
                        from urllib.request import pathname2url
                        path = urljoin('file:', pathname2url(absPath))

                dataType = 'json'
                if hasattr(args, 'assetPackage') and args.assetPackage != None:
                    dataType = 'zip'
                else:
                    import mimetypes
                    inputType = mimetypes.MimeTypes().guess_type(path)[0]
                    if inputType == 'application/zip' or inputType == 'application/octet-stream':
                        dataType = 'zip'
                headers = { "Content-Type": "application/" + dataType }

                headers['User-Agent'] = 'PDFreactor Python Command Line API v8'
                headers['X-RO-User-Agent'] = 'PDFreactor Python Command Line API v8'
                if dataType == 'json':
                    configuration['document'] = path
                    data = json.dumps(configuration)
                elif dataType == 'zip':
                    import os, urlparse
                    parsedUrl = urlparse.urlparse(path)
                    finalPath = os.path.abspath(os.path.join(parsedUrl.netloc, parsedUrl.path))
                    try:
                        data = open(finalPath, 'r').read()
                    except Exception as e:
                        sys.exit("Could not load asset package: " + str(e))
                try:
                    if sys.version_info[0] == 2:
                        req = urllib2.Request(serverUrl + "/convert.json", data, headers)
                        response = urllib2.urlopen(req)
                    else:
                        req = urllib.request.Request(serverUrl + "/convert.json", data.encode(), headers)
                        response = urllib.request.urlopen(req)
                    res = response.read()
                    res = json.loads(res.decode('utf8'))
                    if (hasattr(args, 'logLevel') and args.logLevel != None and args.logLevel != "NONE"):
                        if (res["log"] != None and len(res["log"]) > 0):
                            log("Logging at log level "+args.logLevel+":")
                            records = res["log"]["records"]
                            for record in records:
                                timestamp = record["timestamp"]
                                timestamp = datetime.datetime.fromtimestamp(float(timestamp)/1000).strftime("%H:%M:%S")
                                log("       "+timestamp+" "+record["message"])
                        else:
                            log("No log output at log level " + args.logLevel)
                    if ("error" in res):
                        log("Error while trying to create PDF (code RO103):")
                        log("[" + res["error"] + "]")
                    elif ("document" in res):
                        docNumber = writeOutputFiles(res["document"], docNumber, 0, outputType)
                    elif ("documentArray" in res):
                        pageNumber = 1
                        for document in res["documentArray"]:
                            writeOutputFiles(document, docNumber, pageNumber, outputType)
                            pageNumber += 1
                        docNumber += 1
                except HTTPError as e:
                    if (e.code == 422):
                        log(errrorStr + " " + json.loads(e.read().decode('utf8'))['error'])
                    elif (e.code == 400):
                        log("Invalid client data. " + json.loads(e.read().decode('utf8'))['error'])
                    elif (e.code == 401):
                        log("Unauthorized. " + json.loads(e.read().decode('utf8'))['error'])
                    elif (e.code == 413):
                        log("The configuration is too large to process.")
                    elif (e.code == 500):
                        log(errrorStr + " " + json.loads(e.read().decode('utf8'))['error'])
                    elif (e.code == 503):
                        log("PDFreactor Web Service is unavailable.")
                    else:
                        sys.exit(errrorStr + " Please make sure the PDFreactor Web Service is installed and running.\nError: "+str(e))
                except URLError as e:
                    sys.exit("Error connecting to PDFreactor Web Service at "+serverUrl+". Please make sure the PDFreactor Web Service is installed and running.\nError: "+str(e))
                except Exception as e:
                    sys.exit(errrorStr + " Please make sure the PDFreactor Web Service is installed and running.\nError: "+str(e))
except Exception as e2:
    sys.exit(errrorStr + " Please make sure the PDFreactor Web Service is installed and running.\nError: "+str(e2))
