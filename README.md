# RubyWebServer

Assignment:

  You’ll need to create a program for both the server and client side according to the following tasks: 

    1.Create a self-signed certificate generator. The code must create a CA and a certificate signed by that CA.

    2.Create a basic web server with the generated SSL certificates. This server will expose a REST API respond with a certificate expiration date to every request

    3.Create a test connection program for certificate expiration date verification. In this program, you will use a REST API call you developed in #2 to the running server using the generated CA certificate to check the expiration date of the server certificate and will present a result.

    4.Please test your code with the Rake Task Runner. The goal is to run the "Rake test" command which will run your code and check if everything works
    
    
 To start the server please run **rake start or rake**
 
