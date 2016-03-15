module Sinkdown
  class ApiDocument < Document

    attr_accessor :body

    def initialize(site, path, body)
      @path = path
      slugged = @path.gsub('/', '--')
      slugged = slugged.sub(/\.m(d|arkdown)$/i, '.html')
      @url = "/html/#{slugged}"
      @body = body
      @html = nil
    end

    def url
      @url
    end

    def raw
      @body
    end
  end
end
