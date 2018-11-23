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
        !!(@data && @data['errorCode'].to_i.zero?)
      end

      def method_missing(name, *args)
        @data.nil? && super || @data[name.to_s]
      end

      private

      def parse_response_body!
        JSON.parse(@http_response.body) rescue nil
      end

      def underscore(string)
        string.to_s.split(/[A-Z]/).inject([]){ |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
      end
    end
  end
end
