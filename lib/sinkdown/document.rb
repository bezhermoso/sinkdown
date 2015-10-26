module Sinkdown
  class Document
    
    attr_accessor :path, :url, :html

    def initialize(site, path)
      @path = path
      source_path = Pathname.new site.config[:source]
      file_path = Pathname.new @path
      file_path = file_path.relative_path_from source_path
      file_path = file_path.sub /\.m(d|arkdown)$/i, '.html'
      @url = "/html/#{file_path}"
      @title = nil
      @html = nil
      title
    end

    def url
      @url
    end
    
    def title
      unless @title
        if @html
          header = /<h[1-6]>(.*)<\/h[1-6]>$/
          match = header.match(html)
          if match
            @title = match[1]
          else
            @title = @path
          end
        end
      end
      @title
    end

    def raw
      File.read @path
    end

    def to_liquid
      {
        "path" => self.path,
        "url" => self.url,
        "title" => self.title
      }
    end

    def to_json
      to_liquid
    end
  end
end
