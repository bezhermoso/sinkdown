require 'nokogiri'
require 'sinkdown/renderer'
require 'sinkdown/markdown_watcher'
require 'sinkdown/site_watcher'
require 'sinkdown/server'
require 'sinkdown/document'
require 'sinkdown/index_document'

module Sinkdown
  class Site

    attr_accessor :config, :renderer, :watcher, :server, :documents

    def initialize(config)
      @config = config
      @renderer = Renderer.new(self)
      @documents = Array.new
      @watcher = nil
      @server = nil
    end

    def run
      cleanup
      prepare
      scan_for_documents
      render_existing
      rebuild_site_index
      watch
      start_server
    end

    def cleanup
      FileUtils.rm_rf(@config[:sinkdown_dir]) if File.directory?(@config[:sinkdown_dir])
    end

    def prepare
      unless File.directory? @config[:site_dir]
        FileUtils.mkdir_p @config[:site_dir]
      end
      @index_document = IndexDocument.new self
    end

    def scan_for_documents
      @documents.clear
      @documents << IndexDocument.new(self)
      Dir.glob(File.join(@config[:source], '**/*.{md,markdown}')) do |file|
        @documents << Document.new(self, file)
      end
    end

    def render_existing
      @documents.each do |document|
        process document
        write document
      end
    end

    def process(document)
      html = @renderer.markdown_to_html document.raw
      document.html = html
      title = guess_title(document) || '(no title)'
      document.title = title
    end

    def guess_title(document)
      if document.html
        page = Nokogiri::HTML(document.html)
        first_header = page.at_css('h1,h2,h3')
        if first_header
          first_header.content
        end
      end
    end

    def write(document)
      destination = File.join @config[:sinkdown_dir], document.url
      dir = File.dirname destination
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      full_html = @renderer.render_document document
      File.open(destination, 'w') do |f|
        f.write full_html
      end
    end

    def find_document_by_path(path)
      @documents.select do |document|
        document.path == path
      end.first
    end

    def find_document_by_url(url)
      @documents.select do |document|
        document.url == url
      end.first
    end

    def watch
      @markdown_watcher = MarkdownWatcher.new
      @markdown_watcher.start self
      @watcher = SiteWatcher.new
      @watcher.start self
    end

    def rebuild_site_index
      html = @renderer.render_index @index_document
      File.open(File.join(@config[:sinkdown_dir], 'index.html'), 'w') do |f|
        f.write html
      end
    end

    def start_server
      @server = Server.new
      @server.serve self
    end

    def to_liquid
      {
        "documents" => @documents
      }
    end
  end
end
