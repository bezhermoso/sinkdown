require 'filewatcher'

module Sinkdown
  class SiteWatcher

    attr_accessor :listener, :watcher

    def initialize
      @listeners = Array.new
      @watcher = nil
    end

    def add_listener(listener)
      @listeners << listener
    end

    def remove_listener(listener)
      index = @listeners.find_index listener
      if index
        @listeners.delete_at index
      end
    end

    def start(site)
      site_path = Pathname.new site.config[:sinkdown_dir]
      glob = File.join(site.config[:sinkdown_dir], '**/*.html')
      @watcher = FileWatcher.new glob
      Thread.new(watcher) do |w|
        w.watch do |file|
          file_path = Pathname.new file
          url = "/#{file_path.relative_path_from(site_path)}"
          doc_event = Hash.new
          document = site.find_document_by_url url
          doc_event[:document] = {
            "url" => document.url,
            "title" => document.title,
            "path" => document.path
          }
          @listeners.each { |listener| listener.call doc_event }
        end
      end
    end

    def <<(callable)
      @listeners << callable
    end
  end
end
