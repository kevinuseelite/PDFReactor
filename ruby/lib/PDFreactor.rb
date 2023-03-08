# RealObjects PDFreactor Ruby Client version 7
# https://www.pdfreactor.com
# 
# Released under the following license:
# 
# The MIT License (MIT)
# 
# Copyright (c) 2015-2023 RealObjects GmbH
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'cgi'
require 'net/http'
require 'uri'
require 'json'
# Returns a PDFreactor configuration object
# @private
class PDFreactor
    attr_accessor :apiKey
    @serviceUrl = nil
    def initialize(url="http://localhost:9423/service/rest")
        @serviceUrl = (url == nil) ? "http://localhost:9423/service/rest" : url
        @apiKey = nil
        if @serviceUrl.end_with?("/")
            @serviceUrl = @serviceUrl[0...-1]
        end
    end
    def convertAsync(config, connectionSettings = nil)
        documentId = nil
        uriStr = @serviceUrl + '/convert/async.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        if config != nil
            config['clientName'] = "RUBY";
            config['clientVersion'] = VERSION;
        end
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Post.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req.body = config.to_json
        req.content_type = 'application/json'
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    if !([200, 201, 202, 204].include? res.code.to_i)
                        result = JSON.parse(res.body)
                    end
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            location = res['Location'].to_s
                            if location != nil
                                documentId = location[(location.rindex(/\//) + 1)..-1]
                            end
                            responseCookies = res['Set-Cookie'].to_s
                            if responseCookies != nil && connectionSettings != nil
                                if connectionSettings[:cookies] == nil
                                    connectionSettings[:cookies] = {}
                                end
                                responseCookies.split(/[,]\s?/).each do |pairs|
                                    name, values = pairs.split('=',2)
                                    next unless name and values
                                    name = CGI::unescape(name)
                                    value = values.split(';')[0]
                                    connectionSettings[:cookies][name] = value
                                end
                            end
                            return documentId
                        when 422
                            errorMessage = result["error"]
                        when 400
                            errorMessage = 'Invalid client data. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 413
                            errorMessage = 'The configuration is too large to process.'
                        when 500
                            errorMessage = result["error"]
                        when 503
                            errorMessage = 'Asynchronous conversions are unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def convert(config, connectionSettings = nil)
        uriStr = @serviceUrl + '/convert.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        if config != nil
            config['clientName'] = "RUBY";
            config['clientVersion'] = VERSION;
        end
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Post.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req.body = config.to_json
        req.content_type = 'application/json'
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result["error"]
                        when 400
                            errorMessage = 'Invalid client data. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 413
                            errorMessage = 'The configuration is too large to process.'
                        when 500
                            errorMessage = result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def convertAsBinary(config, stream = nil, connectionSettings = nil)
        uriStr = @serviceUrl + '/convert.bin'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        if stream != nil && stream.is_a?(Hash)
            connectionSettings = stream
            stream = nil
        end
        uri = URI(uriStr)
        if config != nil
            config['clientName'] = "RUBY";
            config['clientVersion'] = VERSION;
        end
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Post.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req.body = config.to_json
        req.content_type = 'application/json'
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        errorMode = true
        begin
            http.start do
                http.request(req) do |res|
                    case res.code.to_i
                        when 200, 201, 202, 204
                            errorMode = false
                    end
                    if stream == nil || errorMode
                        result = res.body
                    else
                        begin
                            res.read_body do |chunk|
                                stream.write(chunk)
                            end
                        ensure
                            stream.close()
                        end
                    end
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result
                        when 400
                            errorMessage = 'Invalid client data. ' + result
                        when 401
                            errorMessage = 'Unauthorized. ' + result
                        when 413
                            errorMessage = 'The configuration is too large to process.'
                        when 500
                            errorMessage = result
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getProgress(documentId, connectionSettings = nil)
        uriStr = @serviceUrl + '/progress/' + documentId + '.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result["error"]
                        when 404
                            errorMessage = 'Document with the given ID was not found. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getDocument(documentId, connectionSettings = nil)
        uriStr = @serviceUrl + '/document/' + documentId + '.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result["error"]
                        when 404
                            errorMessage = 'Document with the given ID was not found. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getDocumentAsBinary(documentId, stream = nil, connectionSettings = nil)
        uriStr = @serviceUrl + '/document/' + documentId + '.bin'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        if stream != nil && stream.is_a?(Hash)
            connectionSettings = stream
            stream = nil
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        errorMode = true
        begin
            http.start do
                http.request(req) do |res|
                    case res.code.to_i
                        when 200, 201, 202, 204
                            errorMode = false
                    end
                    if stream == nil || errorMode
                        result = res.body
                    else
                        begin
                            res.read_body do |chunk|
                                stream.write(chunk)
                            end
                        ensure
                            stream.close()
                        end
                    end
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result
                        when 404
                            errorMessage = 'Document with the given ID was not found. ' + result
                        when 401
                            errorMessage = 'Unauthorized. ' + result
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getDocumentMetadata(documentId, connectionSettings = nil)
        uriStr = @serviceUrl + '/document/metadata/' + documentId + '.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 422
                            errorMessage = result["error"]
                        when 404
                            errorMessage = 'Document with the given ID was not found. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def deleteDocument(documentId, connectionSettings = nil)
        uriStr = @serviceUrl + '/document/' + documentId + '.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Delete.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    if !([200, 201, 202, 204].include? res.code.to_i)
                        result = JSON.parse(res.body)
                    end
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return
                        when 404
                            errorMessage = 'Document with the given ID was not found. ' + result["error"]
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getVersion(connectionSettings = nil)
        uriStr = @serviceUrl + '/version.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return result
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getStatus(connectionSettings = nil)
        uriStr = @serviceUrl + '/status.json'
        if @apiKey != nil
            uriStr += '?apiKey=' + @apiKey
        end
        uri = URI(uriStr)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        req = Net::HTTP::Get.new(uri)
        if connectionSettings != nil && connectionSettings[:headers] != nil
            connectionSettings[:headers].each { |k, v|
                lck = k.downcase
                next if lck.eql? "user-agent"
                next if lck.eql? "content-type"
                next if lck.eql? "range"
                req[k] = v
            }
        end
        cookieStr = ""
        if connectionSettings != nil && connectionSettings[:cookies] != nil
            connectionSettings[:cookies].each { |k, v|
                cookieStr += "#{k}=#{v}; "
            }
        end
        unless cookieStr.to_s.empty?
            req["Cookie"] = cookieStr[0..-3]
        end
        req['User-Agent'] = 'PDFreactor Ruby API v7'
        req['X-RO-User-Agent'] = 'PDFreactor Ruby API v7'
        result = nil
        errorMessage = nil
        errorId = nil
        begin
            http.start do
                http.request(req) do |res|
                    result = JSON.parse(res.body)
                    errorId = res['X-RO-Error-ID'].to_s
                    case res.code.to_i
                        when 200, 201, 202, 204
                            return
                        when 401
                            errorMessage = 'Unauthorized. ' + result["error"]
                        when 503
                            errorMessage = 'PDFreactor Web Service is unavailable.'
                        else
                            errorMessage = 'PDFreactor Web Service error (status: ' + res.code + ').'
                    end
                end
            end
        rescue StandardError => e
            raise PDFreactor::UnreachableServiceError.new('Error connecting to PDFreactor Web Service at ' + @serviceUrl + '. Please make sure the PDFreactor Web Service is installed and running (Error: ' + e.message + ')')
        end
        if errorMessage.nil?
            raise PDFreactor::UnreachableServiceError.new(errorMessage)
        else
            raise _createServerError(errorId, errorMessage, result)
        end
    end
    def getDocumentUrl(documentId)
        return @serviceUrl + "/document/" + documentId
    end
    def getProgressUrl(documentId)
        return @serviceUrl + "/progress/" + documentId
    end
    VERSION = 7
    def _createServerError(errorId = nil, message = nil, result = nil)
        case errorId
            when "asyncUnavailable"
                return PDFreactor::AsyncUnavailableError.new(errorId, message, result)
            when "badRequest"
                return PDFreactor::BadRequestError.new(errorId, message, result)
            when "commandRejected"
                return PDFreactor::CommandRejectedError.new(errorId, message, result)
            when "conversionAborted"
                return PDFreactor::ConversionAbortedError.new(errorId, message, result)
            when "conversionFailure"
                return PDFreactor::ConversionFailureError.new(errorId, message, result)
            when "documentNotFound"
                return PDFreactor::DocumentNotFoundError.new(errorId, message, result)
            when "resourceNotFound"
                return PDFreactor::ResourceNotFoundError.new(errorId, message, result)
            when "invalidClient"
                return PDFreactor::InvalidClientError.new(errorId, message, result)
            when "invalidConfiguration"
                return PDFreactor::InvalidConfigurationError.new(errorId, message, result)
            when "noConfiguration"
                return PDFreactor::NoConfigurationError.new(errorId, message, result)
            when "noInputDocument"
                return PDFreactor::NoInputDocumentError.new(errorId, message, result)
            when "requestRejected"
                return PDFreactor::RequestRejectedError.new(errorId, message, result)
            when "serviceUnavailable"
                return PDFreactor::ServiceUnavailableError.new(errorId, message, result)
            when "unauthorized"
                return PDFreactor::UnauthorizedError.new(errorId, message, result)
            when "unprocessableConfiguration"
                return PDFreactor::UnprocessableConfigurationError.new(errorId, message, result)
            when "unprocessableInput"
                return PDFreactor::UnprocessableInputError.new(errorId, message, result)
            when "notAcceptable"
                return PDFreactor::NotAcceptableError.new(errorId, message, result)
            else
                return PDFreactor::ServerError.new(errorId, message, result)
        end
    end
    class PDFreactorWebserviceError < StandardError
        def initialize(message = 'Unknown PDFreactor Web Service error')
            super(message)
        end
    end
    class ServerError < PDFreactorWebserviceError
        attr_reader :result
        attr_reader :errorId
        def initialize(errorId = nil, message = nil, result = nil)
            @result = result
            @errorId = errorId
            super(message)
        end
    end
    class ClientError < PDFreactorWebserviceError
        attr_reader :result
        def initialize(message)
            super(message)
        end
    end
    class AsyncUnavailableError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class BadRequestError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class CommandRejectedError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class ConversionAbortedError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class ConversionFailureError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class DocumentNotFoundError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class ResourceNotFoundError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class InvalidClientError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class InvalidConfigurationError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class NoConfigurationError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class NoInputDocumentError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class RequestRejectedError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class ServiceUnavailableError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class UnauthorizedError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class UnprocessableConfigurationError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class UnprocessableInputError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class NotAcceptableError < ServerError
        def initialize(errorId, message, result)
            super(errorId, message, result)
        end
    end
    class UnreachableServiceError < ClientError
        def initialize(message)
            super(message)
        end
    end
    class InvalidServiceError < ClientError
        def initialize(message)
            super(message)
        end
    end
    class CallbackType
        FINISH = "FINISH"
        PROGRESS = "PROGRESS"
        START = "START"
    end
    class Cleanup
        CYBERNEKO = "CYBERNEKO"
        JTIDY = "JTIDY"
        NONE = "NONE"
        TAGSOUP = "TAGSOUP"
    end
    class ColorSpace
        CMYK = "CMYK"
        RGB = "RGB"
    end
    class Conformance
        PDF = "PDF"
        PDFA1A = "PDFA1A"
        PDFA1A_PDFUA1 = "PDFA1A_PDFUA1"
        PDFA1B = "PDFA1B"
        PDFA2A = "PDFA2A"
        PDFA2A_PDFUA1 = "PDFA2A_PDFUA1"
        PDFA2B = "PDFA2B"
        PDFA2U = "PDFA2U"
        PDFA3A = "PDFA3A"
        PDFA3A_PDFUA1 = "PDFA3A_PDFUA1"
        PDFA3B = "PDFA3B"
        PDFA3U = "PDFA3U"
        PDFUA1 = "PDFUA1"
        PDFX1A_2001 = "PDFX1A_2001"
        PDFX1A_2003 = "PDFX1A_2003"
        PDFX3_2002 = "PDFX3_2002"
        PDFX3_2003 = "PDFX3_2003"
        PDFX4 = "PDFX4"
        PDFX4P = "PDFX4P"
    end
    class ContentType
        BINARY = "BINARY"
        BMP = "BMP"
        GIF = "GIF"
        HTML = "HTML"
        JPEG = "JPEG"
        JSON = "JSON"
        NONE = "NONE"
        PDF = "PDF"
        PNG = "PNG"
        TEXT = "TEXT"
        TIFF = "TIFF"
        XML = "XML"
    end
    class CssPropertySupport
        ALL = "ALL"
        HTML = "HTML"
        HTML_THIRD_PARTY = "HTML_THIRD_PARTY"
        HTML_THIRD_PARTY_LENIENT = "HTML_THIRD_PARTY_LENIENT"
    end
    class Doctype
        AUTODETECT = "AUTODETECT"
        HTML5 = "HTML5"
        XHTML = "XHTML"
        XML = "XML"
    end
    class Encryption
        NONE = "NONE"
        TYPE_128 = "TYPE_128"
        TYPE_40 = "TYPE_40"
    end
    class ErrorPolicy
        CONFORMANCE_VALIDATION_UNAVAILABLE = "CONFORMANCE_VALIDATION_UNAVAILABLE"
        LICENSE = "LICENSE"
        MISSING_RESOURCE = "MISSING_RESOURCE"
        UNCAUGHT_JAVASCRIPT_EXCEPTION = "UNCAUGHT_JAVASCRIPT_EXCEPTION"
    end
    class ExceedingContentAgainst
        NONE = "NONE"
        PAGE_BORDERS = "PAGE_BORDERS"
        PAGE_CONTENT = "PAGE_CONTENT"
        PARENT = "PARENT"
    end
    class ExceedingContentAnalyze
        CONTENT = "CONTENT"
        CONTENT_AND_BOXES = "CONTENT_AND_BOXES"
        CONTENT_AND_STATIC_BOXES = "CONTENT_AND_STATIC_BOXES"
        NONE = "NONE"
    end
    class HttpsMode
        LENIENT = "LENIENT"
        STRICT = "STRICT"
    end
    class JavaScriptDebugMode
        EXCEPTIONS = "EXCEPTIONS"
        FUNCTIONS = "FUNCTIONS"
        LINES = "LINES"
        NONE = "NONE"
        POSITIONS = "POSITIONS"
    end
    class JavaScriptMode
        DISABLED = "DISABLED"
        ENABLED = "ENABLED"
        ENABLED_NO_LAYOUT = "ENABLED_NO_LAYOUT"
        ENABLED_REAL_TIME = "ENABLED_REAL_TIME"
        ENABLED_TIME_LAPSE = "ENABLED_TIME_LAPSE"
    end
    class KeystoreType
        JKS = "JKS"
        PKCS12 = "PKCS12"
    end
    class LogLevel
        DEBUG = "DEBUG"
        FATAL = "FATAL"
        INFO = "INFO"
        NONE = "NONE"
        PERFORMANCE = "PERFORMANCE"
        WARN = "WARN"
    end
    class MediaFeature
        ASPECT_RATIO = "ASPECT_RATIO"
        COLOR = "COLOR"
        COLOR_INDEX = "COLOR_INDEX"
        DEVICE_ASPECT_RATIO = "DEVICE_ASPECT_RATIO"
        DEVICE_HEIGHT = "DEVICE_HEIGHT"
        DEVICE_WIDTH = "DEVICE_WIDTH"
        GRID = "GRID"
        HEIGHT = "HEIGHT"
        MONOCHROME = "MONOCHROME"
        ORIENTATION = "ORIENTATION"
        RESOLUTION = "RESOLUTION"
        WIDTH = "WIDTH"
    end
    class MergeMode
        APPEND = "APPEND"
        ARRANGE = "ARRANGE"
        OVERLAY = "OVERLAY"
        OVERLAY_BELOW = "OVERLAY_BELOW"
        PREPEND = "PREPEND"
    end
    class OutputIntentDefaultProfile
        FOGRA39 = "Coated FOGRA39"
        GRACOL = "Coated GRACoL 2006"
        IFRA = "ISO News print 26% (IFRA)"
        JAPAN = "Japan Color 2001 Coated"
        JAPAN_NEWSPAPER = "Japan Color 2001 Newspaper"
        JAPAN_UNCOATED = "Japan Color 2001 Uncoated"
        JAPAN_WEB = "Japan Web Coated (Ad)"
        SWOP = "US Web Coated (SWOP) v2"
        SWOP_3 = "Web Coated SWOP 2006 Grade 3 Paper"
    end
    class OutputType
        BMP = "BMP"
        GIF = "GIF"
        GIF_DITHERED = "GIF_DITHERED"
        JPEG = "JPEG"
        PDF = "PDF"
        PNG = "PNG"
        PNG_AI = "PNG_AI"
        PNG_TRANSPARENT = "PNG_TRANSPARENT"
        PNG_TRANSPARENT_AI = "PNG_TRANSPARENT_AI"
        TIFF_CCITT_1D = "TIFF_CCITT_1D"
        TIFF_CCITT_1D_DITHERED = "TIFF_CCITT_1D_DITHERED"
        TIFF_CCITT_GROUP_3 = "TIFF_CCITT_GROUP_3"
        TIFF_CCITT_GROUP_3_DITHERED = "TIFF_CCITT_GROUP_3_DITHERED"
        TIFF_CCITT_GROUP_4 = "TIFF_CCITT_GROUP_4"
        TIFF_CCITT_GROUP_4_DITHERED = "TIFF_CCITT_GROUP_4_DITHERED"
        TIFF_LZW = "TIFF_LZW"
        TIFF_PACKBITS = "TIFF_PACKBITS"
        TIFF_UNCOMPRESSED = "TIFF_UNCOMPRESSED"
    end
    class OverlayRepeat
        ALL_PAGES = "ALL_PAGES"
        LAST_PAGE = "LAST_PAGE"
        NONE = "NONE"
        TRIM = "TRIM"
    end
    class PageOrder
        BOOKLET = "BOOKLET"
        BOOKLET_RTL = "BOOKLET_RTL"
        EVEN = "EVEN"
        ODD = "ODD"
        REVERSE = "REVERSE"
    end
    class PagesPerSheetDirection
        DOWN_LEFT = "DOWN_LEFT"
        DOWN_RIGHT = "DOWN_RIGHT"
        LEFT_DOWN = "LEFT_DOWN"
        LEFT_UP = "LEFT_UP"
        RIGHT_DOWN = "RIGHT_DOWN"
        RIGHT_UP = "RIGHT_UP"
        UP_LEFT = "UP_LEFT"
        UP_RIGHT = "UP_RIGHT"
    end
    class PdfScriptTriggerEvent
        AFTER_PRINT = "AFTER_PRINT"
        AFTER_SAVE = "AFTER_SAVE"
        BEFORE_PRINT = "BEFORE_PRINT"
        BEFORE_SAVE = "BEFORE_SAVE"
        CLOSE = "CLOSE"
        OPEN = "OPEN"
    end
    class ProcessingPreferences
        SAVE_MEMORY_IMAGES = "SAVE_MEMORY_IMAGES"
    end
    class QuirksMode
        DETECT = "DETECT"
        QUIRKS = "QUIRKS"
        STANDARDS = "STANDARDS"
    end
    class ResolutionUnit
        DPCM = "DPCM"
        DPI = "DPI"
        DPPX = "DPPX"
        TDPCM = "TDPCM"
        TDPI = "TDPI"
        TDPPX = "TDPPX"
    end
    class ResourceType
        ATTACHMENT = "ATTACHMENT"
        DOCUMENT = "DOCUMENT"
        FONT = "FONT"
        ICC_PROFILE = "ICC_PROFILE"
        IFRAME = "IFRAME"
        IMAGE = "IMAGE"
        LICENSEKEY = "LICENSEKEY"
        MERGE_DOCUMENT = "MERGE_DOCUMENT"
        OBJECT = "OBJECT"
        RUNNING_DOCUMENT = "RUNNING_DOCUMENT"
        SCRIPT = "SCRIPT"
        STYLESHEET = "STYLESHEET"
        UNKNOWN = "UNKNOWN"
        XHR = "XHR"
    end
    class SigningMode
        SELF_SIGNED = "SELF_SIGNED"
        VERISIGN_SIGNED = "VERISIGN_SIGNED"
        WINCER_SIGNED = "WINCER_SIGNED"
    end
    class ViewerPreferences
        CENTER_WINDOW = "CENTER_WINDOW"
        DIRECTION_L2R = "DIRECTION_L2R"
        DIRECTION_R2L = "DIRECTION_R2L"
        DISPLAY_DOC_TITLE = "DISPLAY_DOC_TITLE"
        DUPLEX_FLIP_LONG_EDGE = "DUPLEX_FLIP_LONG_EDGE"
        DUPLEX_FLIP_SHORT_EDGE = "DUPLEX_FLIP_SHORT_EDGE"
        DUPLEX_SIMPLEX = "DUPLEX_SIMPLEX"
        FIT_WINDOW = "FIT_WINDOW"
        HIDE_MENUBAR = "HIDE_MENUBAR"
        HIDE_TOOLBAR = "HIDE_TOOLBAR"
        HIDE_WINDOW_UI = "HIDE_WINDOW_UI"
        NON_FULLSCREEN_PAGE_MODE_USE_NONE = "NON_FULLSCREEN_PAGE_MODE_USE_NONE"
        NON_FULLSCREEN_PAGE_MODE_USE_OC = "NON_FULLSCREEN_PAGE_MODE_USE_OC"
        NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES = "NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES"
        NON_FULLSCREEN_PAGE_MODE_USE_THUMBS = "NON_FULLSCREEN_PAGE_MODE_USE_THUMBS"
        PAGE_LAYOUT_ONE_COLUMN = "PAGE_LAYOUT_ONE_COLUMN"
        PAGE_LAYOUT_SINGLE_PAGE = "PAGE_LAYOUT_SINGLE_PAGE"
        PAGE_LAYOUT_TWO_COLUMN_LEFT = "PAGE_LAYOUT_TWO_COLUMN_LEFT"
        PAGE_LAYOUT_TWO_COLUMN_RIGHT = "PAGE_LAYOUT_TWO_COLUMN_RIGHT"
        PAGE_LAYOUT_TWO_PAGE_LEFT = "PAGE_LAYOUT_TWO_PAGE_LEFT"
        PAGE_LAYOUT_TWO_PAGE_RIGHT = "PAGE_LAYOUT_TWO_PAGE_RIGHT"
        PAGE_MODE_FULLSCREEN = "PAGE_MODE_FULLSCREEN"
        PAGE_MODE_USE_ATTACHMENTS = "PAGE_MODE_USE_ATTACHMENTS"
        PAGE_MODE_USE_NONE = "PAGE_MODE_USE_NONE"
        PAGE_MODE_USE_OC = "PAGE_MODE_USE_OC"
        PAGE_MODE_USE_OUTLINES = "PAGE_MODE_USE_OUTLINES"
        PAGE_MODE_USE_THUMBS = "PAGE_MODE_USE_THUMBS"
        PICKTRAYBYPDFSIZE_FALSE = "PICKTRAYBYPDFSIZE_FALSE"
        PICKTRAYBYPDFSIZE_TRUE = "PICKTRAYBYPDFSIZE_TRUE"
        PRINTSCALING_APPDEFAULT = "PRINTSCALING_APPDEFAULT"
        PRINTSCALING_NONE = "PRINTSCALING_NONE"
    end
    class XmpPriority
        HIGH = "HIGH"
        LOW = "LOW"
        NONE = "NONE"
    end
end
