require 'sberbank/acquiring/version'
require 'net/http'
require 'json'

module Sberbank
  module Acquiring
    class RestClient
      URI_TEMPLATE = 'https://3dsec.sberbank.ru/payment/rest/%s.do'.freeze

      def initialize(username:, password:)
        @username = username
        @password = password
      end

      def get(action, params = {})
        uri = URI.parse(format(URI_TEMPLATE, camel_case_lower(action)))
        uri.query = URI.encode_www_form(default_params.merge!(params))

        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          JSON.parse(http.request(Net::HTTP::Get.new(uri)).body)
        end
      end

      private

      attr_reader :username, :password

      def default_params
        { 'userName' => username, 'password' => password }
      end

      def camel_case_lower(string)
        string.to_s.split('_').inject([]){ |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
      end
    end
  end
end
