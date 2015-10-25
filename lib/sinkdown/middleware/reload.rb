require 'faye'
require 'json'

module Sinkdown
  module Middleware
    class Reload

      def initialize(app = nil, options = nil)
        @app = app
        @site = options[:site]
        @listeners = Hash.new
      end

      def call(env)
        if Faye::WebSocket.websocket? env
          ws = Faye::WebSocket.new env
          ws.on :open do |event|
            listener = lambda do |doc_event|
              if ws
                msg = {
                  "document" => doc_event[:document].to_json
                }
                ws.send msg.to_json
              end
            end
            @listeners[ws] = listener
            @site.watcher << listener
          end
          ws.on :close do |event|
            listener = @listeners[ws]
            if listener
              @site.watcher.remove_listener listener
            end
            @listeners.delete(ws)
            ws = nil
          end
          ws.rack_response
        else
          @app.call env
        end
      end
    end
  end
end
