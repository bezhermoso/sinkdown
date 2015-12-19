module Sinkdown
  class Document
    
    attr_accessor :path, :url, :html, :title

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
    
    def raw
      File.read @path
    end

    def to_liquid
      {
        "path" => self.path,
        "url" => self.url,
        "title" => self.title,
        "html" => self.html
      }
    end
  end
end
