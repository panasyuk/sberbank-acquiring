# frozen_string_literal: true

require 'net/http'
require 'uri'

module Sberbank
  module Acquiring
    class Request
      TEST_HOST = '3dsec.sberbank.ru'.freeze
      PRODUCTION_HOST = 'securepayments.sberbank.ru'.freeze

      attr_reader :path, :params, :response, :test, :http_request, :host
      alias test? test
      alias http http_request

      def initialize(host: nil, params:, path:, test: false)
        @host        = host || test && TEST_HOST || PRODUCTION_HOST
        @params      = params
        @path        = path
        @test        = test
      end

      def build_uri
        URI::HTTPS.build(host: host, path: path, query: URI.encode_www_form(params))
      end

      def perform
        uri = build_uri
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          @http_request = Net::HTTP::Get.new(uri)
          @response = Response.new(http_response: http.request(@http_request), request: self)
        end
      end
    end
  end
end
