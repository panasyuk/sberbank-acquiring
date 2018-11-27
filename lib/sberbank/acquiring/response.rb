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

      def error?
        @data.nil? || @data['errorCode'].to_i > 0
      end

      def success?
        !error?
      end

      def method_missing(name, *args)
        @data && @data.key?(name.to_s) && @data[name.to_s] || super
      end

      private

      def parse_response_body!
        JSON.parse(@http_response.body)
      rescue JSON::ParserError
      end

      def underscore(string)
        string.
          to_s.
          split(/[A-Z]/).
          inject([]){ |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.
          join
      end
    end
  end
end
