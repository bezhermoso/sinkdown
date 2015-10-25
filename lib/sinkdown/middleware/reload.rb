require 'faye'
require 'json'

module Sinkdown
  module Middleware
    class Reload

      def initialize(app = nil, options = nil)
        @app = app
        @site = options[:site]
      end

      def call(env)
        if Faye::WebSocket.websocket? env
          ws = Faye::WebSocket.new env
          ws.on :open do |event|
            listener = lambda do |doc_event|
              puts doc_event
              msg = {
                "document" => doc_event[:document].to_json
              }
              ws.send msg.to_json
            end
            @site.watcher << listener
          end
          ws.rack_response
        else
          @app.call env
        end
      end
    end
  end
end
