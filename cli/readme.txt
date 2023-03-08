Important:

The python command line interface is a client for the PDFreactor Web Service. By default, it assumes a PDFreactor Web Service is installed on 
the same machine it is excuted on (i.e. http://localhost:9432/service/rest).

If your Web Service is installed on a different host or if you want to test the python CLI using the PDFreactor Demo Web Service, please specify 
which service to use using the "-s" parameter.

Example 1: using the python CLI with a PDFreactor Web Service being locally installed:

python.exe pdfreactor.py -i http://someserver.com/somedoc.html -o C:\Users\testuser\out.pdf

Example 2: using the python CLI with the PDFreactor Demo Web Service

python.exe pdfreactor.py -s https://cloud.pdfreactor.com/service/rest http://someserver.com/somedoc.html -o C:\Users\testuser\out.pdf

Note that if you are using a Web Service that is not part of your local network, it may not be able to access resources within your local network.
