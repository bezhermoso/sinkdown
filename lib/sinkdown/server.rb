require 'rack'
require 'faye'
require 'sinkdown/middleware/reload'
require 'sinkdown/middleware/redirect_home'

module Sinkdown
  class Server
    def initialize
      Faye::WebSocket.load_adapter 'thin'
      @thin = Rack::Handler.get 'thin'
    end

    def serve(site)

      app = Rack::Builder.new do
        use Sinkdown::Middleware::Reload,
          :site => site

        use Faye::RackAdapter,
          :mount => '/faye',
          :timeout => 25

        # Serve Markdown -> HTML files
        use Rack::Static,
          :urls => ['/html'],
          :root => site.config[:sinkdown_dir],
          :index => 'index.html'

        use Rack::Static,
          :urls => ['/css', '/js'],
          :root => File.dirname(__FILE__) + '/assets'
        run Sinkdown::Middleware::RedirectHome
      end

      @thin.run app, :Port => site.config[:port]
    end
  end
end
