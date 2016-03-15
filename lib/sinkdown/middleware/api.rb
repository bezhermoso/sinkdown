require "sinkdown/api_document"

module Sinkdown
  module Middleware
    class Api

      def initialize(app = nil, options = nil)
        @app = app
        @site = options[:site]
        @documents = Hash.new
      end

      def create(request)
        post = request.POST
        puts post
        file = post['path']
        body = post['body']

        document = @site.find_document_by_path file
        unless document
          document = Sinkdown::ApiDocument.new(@site, file, body)
          @site.documents << document
        else
          document.body = body
        end

        puts document.inspect
        @site.process document
        @site.write document
        @site.rebuild_site_index
        [201, {"Content-Type" => "text/plain"}, "Created"]
      end

      def delete(env)
        [200, {"Content-Type" => "text/plain"}, "Deleted"]
      end

      def call(env)
        request = Rack::Request.new(env)
        verb = env['REQUEST_METHOD']
        return create(request) if verb == 'POST'
        return delete(request) if verb == 'DELETE'
        @app.call env
      end

    end
  end
end
