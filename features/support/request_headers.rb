# Retorna os headers configurados pelo hook para o cenário atual.
def current_request_headers
  @request_headers ||= {}
end

# Monta opções HTTParty combinando headers do cenário com headers específicos do request.
def request_options_with_headers(extra_headers = {})
  headers = current_request_headers.merge(extra_headers)

  headers.empty? ? {} : { headers: headers }
end
