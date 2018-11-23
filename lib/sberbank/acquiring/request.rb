# frozen_string_literal: true

module Sberbank
  module Acquiring
    class Request
      TEST_HOST = '3dsec.sberbank.ru'.freeze
      PRODUCTION_HOST = 'securepayments.sberbank.ru'.freeze

      attr_reader :path, :params, :response, :test, :http_request, :host
      alias test? test
      alias http http_request

      def initialize(credentials:, host: nil, params:, path:, test: false)
        validate_credentials!(credentials)

        @credentials = credentials
        @host        = host || test && TEST_HOST || PRODUCTION_HOST
        @params      = params
        @path        = path
        @test        = test
      end

      def build_uri
        uri = URI.parse("https://#{host}/payment/rest/#{path}.do")
        uri.query = build_query
        uri
      end

      def build_query
        camel_cased_params = {}

        params.merge(@credentials.to_h).each do |k, v|
          next if k.is_a?(String) || k == :userName

          k = k == :username ? 'userName' : camel_case_lower(k)
          v = v.to_json if v.is_a?(Hash)

          camel_cased_params[k] = v
        end

        URI.encode_www_form(camel_cased_params)
      end

      def perform
        uri = build_uri
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          @http_request = Net::HTTP::Get.new(uri)
          @response = Sberbank::Acquiring::Response.new(http_response: http.request(@http_request), request: self)
        end
      end

      private

      def validate_credentials!(credentials)
        unless credentials.is_a?(Sberbank::Acquiring::Credentials)
          raise ArgumentError, "Expected credentials argument to be Sberbank::Acquiring::Credentials but was #{credentials.class.name} instead."
        end
      end

      def camel_case_lower(string)
        string.to_s.split('_').inject([]){ |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
      end
    end
  end
end
