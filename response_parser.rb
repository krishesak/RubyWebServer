# This class have methods to generate a response based on the request
class HttpResponse
  SERVER_ROOT_PATH = 'views'

  def prepare(parsed_request)
    path = parsed_request.fetch(:path)
    if path == '/'
      respond_with(SERVER_ROOT_PATH + "/home.html")
    else
      respond_with(SERVER_ROOT_PATH + path)
    end
  end

  def respond_with(path)
    if File.exists?(path)
      ok_response(File.binread(path))
    else
      not_found_response
    end
  end

  def ok_response(body)
    response_format(200, body)
  end

  def not_found_response
    response_format(404)
  end
  
  # Standard HTTP format
  def response_format(code='', body='')
    "HTTP/1.1 #{code}\r\n" +
    "Content-Length: #{body.size}\r\n" +
    "\r\n" +
    "#{body}\r\n" 
  end
end
