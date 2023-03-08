# RealObjects PDFreactor Perl Client version 8
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

package PDFreactor;
    use LWP::UserAgent;
    use LWP::Protocol::https;
    use HTTP::Request;
    use HTTP::Headers;
    use HTTP::Cookies;
    use JSON;
    
    sub new {
        $self=shift;
        $url=shift;
        if (not(defined($url)) || $url eq "" || $url eq NULL) {
            $url = "http://localhost:9423/service/rest"; 
        }
        if ($url =~ /\/$/) {
            chop($url);
        }
        my $ref={
            apiKey => ""
        };
        bless($ref, $self);
    }
    sub getDocumentUrl {
        my $self = shift;
        my $documentId = shift;
        if (defined($documentId) && not($documentId eq "")) {
            return $url . "/document/" . $documentId;
        }
    }
    sub getProgressUrl {
        my $self = shift;
        my $documentId = shift;
        if (defined($documentId) && not($documentId eq "")) {
            return $url . "/progress/" . $documentId;
        }
    }
    sub convert {
        $self = shift;
        my %config = %{shift()};
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/convert.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(POST => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            my $json = encode_json \%config;
            $request->content($json);
            $request->content_type("application/json; charset=utf-8");
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return decode_json ($response->content);
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 400) {
            die PDFreactor->_createServerException($errorId, "Invalid client data. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 413) {
            die PDFreactor->_createServerException($errorId, "The configuration is too large to process.", $result);
        } elsif ($status == 500) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub convertAsBinary {
        $self = shift;
        my %config = %{shift()};
        my $stream = shift();
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/convert.bin";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(POST => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            my $json = encode_json \%config;
            $request->content($json);
            $request->content_type("application/json; charset=utf-8");
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        }
        if (!$errorMode) {
            if (defined $stream) {
                binmode($stream);
                $bytes = 2 * 1024;
                $chunk = $response->content($bytes);
                while ($chunk ne $bytes) {
                    $stream->write($chunk);
                    $chunk = $response->content($bytes);
                }
                close($stream);
            } else {
                return $response->content;
            }
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $response->content, NULL);
        } elsif ($status == 400) {
            die PDFreactor->_createServerException($errorId, "Invalid client data. ".$response->content, NULL);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$response->content, NULL);
        } elsif ($status == 413) {
            die PDFreactor->_createServerException($errorId, "The configuration is too large to process.", NULL);
        } elsif ($status == 500) {
            die PDFreactor->_createServerException($errorId, $response->content, NULL);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", NULL);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub convertAsync {
        $self = shift;
        my %config = %{shift()};
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/convert/async.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(POST => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            my $json = encode_json \%config;
            $request->content($json);
            $request->content_type("application/json; charset=utf-8");
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            my $location = $response->header("Location");
            $documentId = substr($location, rindex($location, "/") + 1);
            my $cookiesHeader = $response->header('Set-Cookie');
            if (!$cookiesHeader eq '' && defined $connectionSettings) {
                if (!defined $connectionSettings->{cookies}) {
                    $connectionSettings->{cookies} = ();
                }
                $cookie_jar = HTTP::Cookies->new();
                $cookie_jar->extract_cookies($response);
                sub extractCookies {
                    my $version = shift();
                    my $cookieName = shift();
                    my $cookieValue = shift();
                    $connectionSettings->{cookies}->{$cookieName} = $cookieValue;
                }
                $cookie_jar->scan(\&extractCookies);
            }
            return $documentId;
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 400) {
            die PDFreactor->_createServerException($errorId, "Invalid client data. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 413) {
            die PDFreactor->_createServerException($errorId, "The configuration is too large to process.", $result);
        } elsif ($status == 500) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "Asynchronous conversions are unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getProgress {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/progress/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return decode_json ($response->content);
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 404) {
            die PDFreactor->_createServerException($errorId, "Document with the given ID was not found. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getDocument {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/document/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return decode_json ($response->content);
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 404) {
            die PDFreactor->_createServerException($errorId, "Document with the given ID was not found. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getDocumentAsBinary {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $stream = shift();
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/document/" .$documentId. ".bin";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        }
        if (!$errorMode) {
            if (defined $stream) {
                binmode($stream);
                $bytes = 2 * 1024;
                $chunk = $response->content($bytes);
                while ($chunk ne $bytes) {
                    $stream->write($chunk);
                    $chunk = $response->content($bytes);
                }
                close($stream);
            } else {
                return $response->content;
            }
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $response->content, NULL);
        } elsif ($status == 404) {
            die PDFreactor->_createServerException($errorId, "Document with the given ID was not found. ".$response->content, NULL);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$response->content, NULL);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", NULL);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getDocumentMetadata {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/document/metadata/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return decode_json ($response->content);
        } elsif ($status == 422) {
            die PDFreactor->_createServerException($errorId, $result->{'error'}, $result);
        } elsif ($status == 404) {
            die PDFreactor->_createServerException($errorId, "Document with the given ID was not found. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub deleteDocument {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/document/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(DELETE => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return;
        } elsif ($status == 404) {
            die PDFreactor->_createServerException($errorId, "Document with the given ID was not found. ".$result->{'error'}, $result);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getVersion {
        $self = shift;
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/version.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return decode_json ($response->content);
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
    }
    sub getStatus {
        $self = shift;
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{cookies}) {
            foreach my $key (keys %{$connectionSettings->{cookies}}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && ref($connectionSettings) eq 'HASH' && defined $connectionSettings->{headers}) {
            foreach my $key (keys %{$connectionSettings->{headers}}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v8");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v8");
        my $restUrl = $url."/status.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $response;
        eval {
            my $request = HTTP::Request->new(GET => $restUrl, $headers);
            my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
            $response = $userAgent->request($request);
        } || do {
            my $e = $@;
            die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: " . $e . ")")
        };
        my $status = $response->code;
        my $errorId = $response->header('X-RO-Error-ID');
        my $result = NULL;
        my $errorMode = 1;
        if ($status >= 200 && $status <= 204) {
            $errorMode = 0;
        } else {
            eval {
                $result = decode_json($response->content);
            } || do {
                my $e = $@;
                die PDFreactor::UnreachableServiceException->new(message => "Error connecting to PDFreactor Web Service at " . $url . ". Please make sure the PDFreactor Web Service is installed and running (Error: Could not parse response)")
            }
        }
        if (!$errorMode) {
            return 1;
        } elsif ($status == 401) {
            die PDFreactor->_createServerException($errorId, "Unauthorized. ".$result->{'error'}, $result);
        } elsif ($status == 503) {
            die PDFreactor->_createServerException($errorId, "PDFreactor Web Service is unavailable.", $result);
        } else {
            die PDFreactor::ServerException.new($errorId, "PDFreactor Web Service error (status: " . $status . ").", NULL);
        }
        return 0;
    }
    use constant VERSION => 8;
    sub _createServerException {
        my ($class, @args) = @_;
        $errorId = $args[0];
        $message = $args[1];
        $result = $args[2];
        if ($errorId eq "server") {
            return PDFreactor::ServerException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "asyncUnavailable") {
            return PDFreactor::AsyncUnavailableException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "badRequest") {
            return PDFreactor::BadRequestException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "commandRejected") {
            return PDFreactor::CommandRejectedException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "conversionAborted") {
            return PDFreactor::ConversionAbortedException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "conversionFailure") {
            return PDFreactor::ConversionFailureException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "documentNotFound") {
            return PDFreactor::DocumentNotFoundException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "resourceNotFound") {
            return PDFreactor::ResourceNotFoundException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "invalidClient") {
            return PDFreactor::InvalidClientException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "invalidConfiguration") {
            return PDFreactor::InvalidConfigurationException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "noConfiguration") {
            return PDFreactor::NoConfigurationException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "noInputDocument") {
            return PDFreactor::NoInputDocumentException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "requestRejected") {
            return PDFreactor::RequestRejectedException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "serviceUnavailable") {
            return PDFreactor::ServiceUnavailableException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "unauthorized") {
            return PDFreactor::UnauthorizedException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "unprocessableConfiguration") {
            return PDFreactor::UnprocessableConfigurationException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "unprocessableInput") {
            return PDFreactor::UnprocessableInputException->new(errorId => $errorId, message => $message, result => $result);
        } elsif ($errorId eq "notAcceptable") {
            return PDFreactor::NotAcceptableException->new(errorId => $errorId, message => $message, result => $result);
        } else {
            return PDFreactor::ServerException->new(errorId => $errorId, message => $message, result => $result);
        }
    }
1;
package PDFreactor::PDFreactorWebserviceException;
    sub new {
        my ($class, %args) = @_;
        return bless \%args, $class;
    };
    sub message {
        my ($self, $value) = @_;
        if (@_ == 2) {
            $self->{message} = $value;
        }
        return $self->{message};
    };
    sub result {
        my ($self, %value) = @_;
        if (@_ == 2) {
            $self->{result} = %value;
        }
        return $self->{result};
    };
    sub errorId {
        my ($self, $value) = @_;
        if (@_ == 2) {
            $self->{errorId} = $value;
        }
        return $self->{errorId};
    };
package PDFreactor::ServerException;
    our @ISA = "PDFreactor::PDFreactorWebserviceException";
    1;
package PDFreactor::ClientException;
    our @ISA = "PDFreactor::PDFreactorWebserviceException";
    1;
package PDFreactor::AsyncUnavailableException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::BadRequestException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::CommandRejectedException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::ConversionAbortedException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::ConversionFailureException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::DocumentNotFoundException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::ResourceNotFoundException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::InvalidClientException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::InvalidConfigurationException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::NoConfigurationException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::NoInputDocumentException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::RequestRejectedException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::ServiceUnavailableException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::UnauthorizedException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::UnprocessableConfigurationException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::UnprocessableInputException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::NotAcceptableException;
    our @ISA = "PDFreactor::ServerException";
    1;
package PDFreactor::UnreachableServiceException;
    our @ISA = "PDFreactor::ClientException";
    1;
package PDFreactor::InvalidServiceException;
    our @ISA = "PDFreactor::ClientException";
    1;
package PDFreactor::CallbackType;
    use constant {
        FINISH => "FINISH",
        PROGRESS => "PROGRESS",
        START => "START",
    };
package PDFreactor::Cleanup;
    use constant {
        CYBERNEKO => "CYBERNEKO",
        JTIDY => "JTIDY",
        NONE => "NONE",
        TAGSOUP => "TAGSOUP",
    };
package PDFreactor::ColorSpace;
    use constant {
        CMYK => "CMYK",
        RGB => "RGB",
    };
package PDFreactor::Conformance;
    use constant {
        PDF => "PDF",
        PDFA1A => "PDFA1A",
        PDFA1A_PDFUA1 => "PDFA1A_PDFUA1",
        PDFA1B => "PDFA1B",
        PDFA2A => "PDFA2A",
        PDFA2A_PDFUA1 => "PDFA2A_PDFUA1",
        PDFA2B => "PDFA2B",
        PDFA2U => "PDFA2U",
        PDFA3A => "PDFA3A",
        PDFA3A_PDFUA1 => "PDFA3A_PDFUA1",
        PDFA3B => "PDFA3B",
        PDFA3U => "PDFA3U",
        PDFUA1 => "PDFUA1",
        PDFX1A_2001 => "PDFX1A_2001",
        PDFX1A_2003 => "PDFX1A_2003",
        PDFX3_2002 => "PDFX3_2002",
        PDFX3_2003 => "PDFX3_2003",
        PDFX4 => "PDFX4",
        PDFX4P => "PDFX4P",
    };
package PDFreactor::ContentType;
    use constant {
        BINARY => "BINARY",
        BMP => "BMP",
        GIF => "GIF",
        HTML => "HTML",
        JPEG => "JPEG",
        JSON => "JSON",
        NONE => "NONE",
        PDF => "PDF",
        PNG => "PNG",
        TEXT => "TEXT",
        TIFF => "TIFF",
        XML => "XML",
    };
package PDFreactor::CssPropertySupport;
    use constant {
        ALL => "ALL",
        HTML => "HTML",
        HTML_THIRD_PARTY => "HTML_THIRD_PARTY",
        HTML_THIRD_PARTY_LENIENT => "HTML_THIRD_PARTY_LENIENT",
    };
package PDFreactor::Doctype;
    use constant {
        AUTODETECT => "AUTODETECT",
        HTML5 => "HTML5",
        XHTML => "XHTML",
        XML => "XML",
    };
package PDFreactor::Encryption;
    use constant {
        NONE => "NONE",
        TYPE_128 => "TYPE_128",
        TYPE_40 => "TYPE_40",
    };
package PDFreactor::ErrorPolicy;
    use constant {
        CONFORMANCE_VALIDATION_UNAVAILABLE => "CONFORMANCE_VALIDATION_UNAVAILABLE",
        LICENSE => "LICENSE",
        MISSING_RESOURCE => "MISSING_RESOURCE",
        UNCAUGHT_JAVASCRIPT_EXCEPTION => "UNCAUGHT_JAVASCRIPT_EXCEPTION",
    };
package PDFreactor::ExceedingContentAgainst;
    use constant {
        NONE => "NONE",
        PAGE_BORDERS => "PAGE_BORDERS",
        PAGE_CONTENT => "PAGE_CONTENT",
        PARENT => "PARENT",
    };
package PDFreactor::ExceedingContentAnalyze;
    use constant {
        CONTENT => "CONTENT",
        CONTENT_AND_BOXES => "CONTENT_AND_BOXES",
        CONTENT_AND_STATIC_BOXES => "CONTENT_AND_STATIC_BOXES",
        NONE => "NONE",
    };
package PDFreactor::HttpsMode;
    use constant {
        LENIENT => "LENIENT",
        STRICT => "STRICT",
    };
package PDFreactor::JavaScriptDebugMode;
    use constant {
        EXCEPTIONS => "EXCEPTIONS",
        FUNCTIONS => "FUNCTIONS",
        LINES => "LINES",
        NONE => "NONE",
        POSITIONS => "POSITIONS",
    };
package PDFreactor::JavaScriptMode;
    use constant {
        DISABLED => "DISABLED",
        ENABLED => "ENABLED",
        ENABLED_NO_LAYOUT => "ENABLED_NO_LAYOUT",
        ENABLED_REAL_TIME => "ENABLED_REAL_TIME",
        ENABLED_TIME_LAPSE => "ENABLED_TIME_LAPSE",
    };
package PDFreactor::KeystoreType;
    use constant {
        JKS => "JKS",
        PKCS12 => "PKCS12",
    };
package PDFreactor::LogLevel;
    use constant {
        DEBUG => "DEBUG",
        FATAL => "FATAL",
        INFO => "INFO",
        NONE => "NONE",
        PERFORMANCE => "PERFORMANCE",
        WARN => "WARN",
    };
package PDFreactor::MediaFeature;
    use constant {
        ASPECT_RATIO => "ASPECT_RATIO",
        COLOR => "COLOR",
        COLOR_INDEX => "COLOR_INDEX",
        DEVICE_ASPECT_RATIO => "DEVICE_ASPECT_RATIO",
        DEVICE_HEIGHT => "DEVICE_HEIGHT",
        DEVICE_WIDTH => "DEVICE_WIDTH",
        GRID => "GRID",
        HEIGHT => "HEIGHT",
        MONOCHROME => "MONOCHROME",
        ORIENTATION => "ORIENTATION",
        RESOLUTION => "RESOLUTION",
        WIDTH => "WIDTH",
    };
package PDFreactor::MergeMode;
    use constant {
        APPEND => "APPEND",
        ARRANGE => "ARRANGE",
        OVERLAY => "OVERLAY",
        OVERLAY_BELOW => "OVERLAY_BELOW",
        PREPEND => "PREPEND",
    };
package PDFreactor::OutputIntentDefaultProfile;
    use constant {
        FOGRA39 => "Coated FOGRA39",
        GRACOL => "Coated GRACoL 2006",
        IFRA => "ISO News print 26% (IFRA)",
        JAPAN => "Japan Color 2001 Coated",
        JAPAN_NEWSPAPER => "Japan Color 2001 Newspaper",
        JAPAN_UNCOATED => "Japan Color 2001 Uncoated",
        JAPAN_WEB => "Japan Web Coated (Ad)",
        SWOP => "US Web Coated (SWOP) v2",
        SWOP_3 => "Web Coated SWOP 2006 Grade 3 Paper",
    };
package PDFreactor::OutputType;
    use constant {
        BMP => "BMP",
        GIF => "GIF",
        GIF_DITHERED => "GIF_DITHERED",
        JPEG => "JPEG",
        PDF => "PDF",
        PNG => "PNG",
        PNG_AI => "PNG_AI",
        PNG_TRANSPARENT => "PNG_TRANSPARENT",
        PNG_TRANSPARENT_AI => "PNG_TRANSPARENT_AI",
        TIFF_CCITT_1D => "TIFF_CCITT_1D",
        TIFF_CCITT_1D_DITHERED => "TIFF_CCITT_1D_DITHERED",
        TIFF_CCITT_GROUP_3 => "TIFF_CCITT_GROUP_3",
        TIFF_CCITT_GROUP_3_DITHERED => "TIFF_CCITT_GROUP_3_DITHERED",
        TIFF_CCITT_GROUP_4 => "TIFF_CCITT_GROUP_4",
        TIFF_CCITT_GROUP_4_DITHERED => "TIFF_CCITT_GROUP_4_DITHERED",
        TIFF_LZW => "TIFF_LZW",
        TIFF_PACKBITS => "TIFF_PACKBITS",
        TIFF_UNCOMPRESSED => "TIFF_UNCOMPRESSED",
    };
package PDFreactor::OverlayRepeat;
    use constant {
        ALL_PAGES => "ALL_PAGES",
        LAST_PAGE => "LAST_PAGE",
        NONE => "NONE",
        TRIM => "TRIM",
    };
package PDFreactor::PageOrder;
    use constant {
        BOOKLET => "BOOKLET",
        BOOKLET_RTL => "BOOKLET_RTL",
        EVEN => "EVEN",
        ODD => "ODD",
        REVERSE => "REVERSE",
    };
package PDFreactor::PagesPerSheetDirection;
    use constant {
        DOWN_LEFT => "DOWN_LEFT",
        DOWN_RIGHT => "DOWN_RIGHT",
        LEFT_DOWN => "LEFT_DOWN",
        LEFT_UP => "LEFT_UP",
        RIGHT_DOWN => "RIGHT_DOWN",
        RIGHT_UP => "RIGHT_UP",
        UP_LEFT => "UP_LEFT",
        UP_RIGHT => "UP_RIGHT",
    };
package PDFreactor::PdfScriptTriggerEvent;
    use constant {
        AFTER_PRINT => "AFTER_PRINT",
        AFTER_SAVE => "AFTER_SAVE",
        BEFORE_PRINT => "BEFORE_PRINT",
        BEFORE_SAVE => "BEFORE_SAVE",
        CLOSE => "CLOSE",
        OPEN => "OPEN",
    };
package PDFreactor::ProcessingPreferences;
    use constant {
        SAVE_MEMORY_IMAGES => "SAVE_MEMORY_IMAGES",
    };
package PDFreactor::QuirksMode;
    use constant {
        DETECT => "DETECT",
        QUIRKS => "QUIRKS",
        STANDARDS => "STANDARDS",
    };
package PDFreactor::ResolutionUnit;
    use constant {
        DPCM => "DPCM",
        DPI => "DPI",
        DPPX => "DPPX",
        TDPCM => "TDPCM",
        TDPI => "TDPI",
        TDPPX => "TDPPX",
    };
package PDFreactor::ResourceType;
    use constant {
        ATTACHMENT => "ATTACHMENT",
        DOCUMENT => "DOCUMENT",
        FONT => "FONT",
        ICC_PROFILE => "ICC_PROFILE",
        IFRAME => "IFRAME",
        IMAGE => "IMAGE",
        LICENSEKEY => "LICENSEKEY",
        MERGE_DOCUMENT => "MERGE_DOCUMENT",
        OBJECT => "OBJECT",
        RUNNING_DOCUMENT => "RUNNING_DOCUMENT",
        SCRIPT => "SCRIPT",
        STYLESHEET => "STYLESHEET",
        UNKNOWN => "UNKNOWN",
        XHR => "XHR",
    };
package PDFreactor::SigningMode;
    use constant {
        SELF_SIGNED => "SELF_SIGNED",
        VERISIGN_SIGNED => "VERISIGN_SIGNED",
        WINCER_SIGNED => "WINCER_SIGNED",
    };
package PDFreactor::ViewerPreferences;
    use constant {
        CENTER_WINDOW => "CENTER_WINDOW",
        DIRECTION_L2R => "DIRECTION_L2R",
        DIRECTION_R2L => "DIRECTION_R2L",
        DISPLAY_DOC_TITLE => "DISPLAY_DOC_TITLE",
        DUPLEX_FLIP_LONG_EDGE => "DUPLEX_FLIP_LONG_EDGE",
        DUPLEX_FLIP_SHORT_EDGE => "DUPLEX_FLIP_SHORT_EDGE",
        DUPLEX_SIMPLEX => "DUPLEX_SIMPLEX",
        FIT_WINDOW => "FIT_WINDOW",
        HIDE_MENUBAR => "HIDE_MENUBAR",
        HIDE_TOOLBAR => "HIDE_TOOLBAR",
        HIDE_WINDOW_UI => "HIDE_WINDOW_UI",
        NON_FULLSCREEN_PAGE_MODE_USE_NONE => "NON_FULLSCREEN_PAGE_MODE_USE_NONE",
        NON_FULLSCREEN_PAGE_MODE_USE_OC => "NON_FULLSCREEN_PAGE_MODE_USE_OC",
        NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES => "NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES",
        NON_FULLSCREEN_PAGE_MODE_USE_THUMBS => "NON_FULLSCREEN_PAGE_MODE_USE_THUMBS",
        PAGE_LAYOUT_ONE_COLUMN => "PAGE_LAYOUT_ONE_COLUMN",
        PAGE_LAYOUT_SINGLE_PAGE => "PAGE_LAYOUT_SINGLE_PAGE",
        PAGE_LAYOUT_TWO_COLUMN_LEFT => "PAGE_LAYOUT_TWO_COLUMN_LEFT",
        PAGE_LAYOUT_TWO_COLUMN_RIGHT => "PAGE_LAYOUT_TWO_COLUMN_RIGHT",
        PAGE_LAYOUT_TWO_PAGE_LEFT => "PAGE_LAYOUT_TWO_PAGE_LEFT",
        PAGE_LAYOUT_TWO_PAGE_RIGHT => "PAGE_LAYOUT_TWO_PAGE_RIGHT",
        PAGE_MODE_FULLSCREEN => "PAGE_MODE_FULLSCREEN",
        PAGE_MODE_USE_ATTACHMENTS => "PAGE_MODE_USE_ATTACHMENTS",
        PAGE_MODE_USE_NONE => "PAGE_MODE_USE_NONE",
        PAGE_MODE_USE_OC => "PAGE_MODE_USE_OC",
        PAGE_MODE_USE_OUTLINES => "PAGE_MODE_USE_OUTLINES",
        PAGE_MODE_USE_THUMBS => "PAGE_MODE_USE_THUMBS",
        PICKTRAYBYPDFSIZE_FALSE => "PICKTRAYBYPDFSIZE_FALSE",
        PICKTRAYBYPDFSIZE_TRUE => "PICKTRAYBYPDFSIZE_TRUE",
        PRINTSCALING_APPDEFAULT => "PRINTSCALING_APPDEFAULT",
        PRINTSCALING_NONE => "PRINTSCALING_NONE",
    };
package PDFreactor::XmpPriority;
    use constant {
        HIGH => "HIGH",
        LOW => "LOW",
        NONE => "NONE",
    };
