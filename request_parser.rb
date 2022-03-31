# This class have methods to parse the request and headers.
class HttpRequest

  def parse(request)
    http_method, path = request.lines[0].split
    {
      method: http_method,
      path: path,
      headers: parse_headers(request)
    }
  end

  def parse_headers(request)
    headers = {}
    request.lines[1..-1].each do |line|
      return headers if line == "\r\n"
      header_name, value = line.split
      header_name = header_name.gsub(':', '').downcase.to_sym
      headers[header_name] = value
    end
  end

end