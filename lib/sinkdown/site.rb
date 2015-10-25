require 'sinkdown/renderer'
require 'sinkdown/markdown_watcher'
require 'sinkdown/site_watcher'
require 'sinkdown/server'
require 'sinkdown/document'
require 'sinkdown/index_document'

module Sinkdown
  class Site

    attr_accessor :config, :renderer, :watcher, :server

    def initialize(config)
      @config = config
      @renderer = Renderer.new(self)
      @documents = Array.new
      @watcher = nil
      @server = nil
    end

    def run
      prepare
      scan_for_documents
      render_existing
      rebuild_site_index
      watch
      start_server
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
        @renderer.convert document
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
      @renderer.render_index
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
