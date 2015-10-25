module Sinkdown
  module Middleware
    class RedirectHome
      def self.call(env)
        [200, {}, ["You shouldn't be here."]]
      end
    end
  end
end
