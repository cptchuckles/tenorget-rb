# Credit to servel333: https://gist.github.com/servel333/6642770

def wget(url, file = nil)
  require 'net/http'
  require 'uri'

  file ||= File.basename(url)

  url = URI.parse(url)
  Net::HTTP.start(url.host) do |http|
    resp = http.get(url.path)
    open(file, 'wb') do |file|
      file.write(resp.body)
    end
  end
end
