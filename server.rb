require 'socket'
require_relative 'request_parser'
require_relative 'response_parser'
require_relative 'self_signed_certificate'

# Generates certificate that signed by CA
my_cert = CertificateGenerator.new

# Setup an SSL session
context = OpenSSL::SSL::SSLContext.new
context.cert = my_cert.signed_cert
context.key = my_cert.private_key

server = TCPServer.new 5000
ssl_server = OpenSSL::SSL::SSLServer.new server, context

puts "Starting the server..."
puts "Press ctrl+c to shutdown the server..."

loop do
  connection = ssl_server.accept
  request = connection.gets

  STDOUT.puts request
  unless request.nil?
    parsed_request = HttpRequest.new.parse(request)

    response = HttpResponse.new.prepare(parsed_request)
    connection.write(response)
  end
  connection.close
end

# tcp_client = TCPSocket.new 'localhost', 5000
# context.ca_file = 'ca_certificate.pem'
# context.verify_mode = OpenSSL::SSL::VERIFY_PEER
# ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context
# ssl_client.connect
# ssl_client.puts "hello server!"
# puts ssl_client.gets