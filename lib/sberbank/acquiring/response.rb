# frozen_string_literal: true

module Sberbank
  module Acquiring
    class Response
      attr_reader :http_response, :request, :data
      alias http http_response

      def initialize(http_response:, request:)
        @http_response = http_response
        @request       = request
        @data          = parse_response_body!
      end

      private

      def parse_response_body!
        JSON.parse(@http_response.body)
      rescue JSON::ParserError
      end
    end
  end
end
