module Sberbank
  module Acquiring
    class Response
      attr_reader :http_response, :request
      alias http http_response

      def initialize(http_response:, request:)
        @http_response = http_response
        @request       = request
      end
    end
  end
end
