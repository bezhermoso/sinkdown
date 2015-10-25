module Sinkdown
  class IndexDocument < Document
    def initialize(site)
      super site, File.join(File.dirname(__FILE__), '/templates/index.html')
      @url = '/index.html'
    end
  end
end
