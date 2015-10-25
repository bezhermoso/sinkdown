require 'filewatcher'
require 'sinkdown/document'

class MarkdownWatcher

  def start(site)
    glob = File.join(site.config[:source], '**/*.{md,markdown}')
    watcher = FileWatcher.new glob
    Thread.new(watcher) do |w|
      w.watch do |file|
        document = site.find_document_by_path file
        unless document
          site.documents << Document.new(site, file)
        end
        site.renderer.convert document
        site.rebuild_site_index
      end
    end
  end
end
