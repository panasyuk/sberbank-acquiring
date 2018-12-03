# frozen_string_literal: true

module Sberbank
  module Acquiring
    class CommandResponseDecorator
      extend Forwardable

      attr_reader :response
      def_delegators :response, :data, :http_response, :http, :request

      def initialize(response)
        @response = response
      end

      def error?
        data.nil? || data['errorCode'].to_i > 0
      end

      def success?
        !error?
      end

      def method_missing(name, *attrs)
        key = camelize_string(name.to_s)
        data.key?(key) && data[key] || super
      end

      private

      def camelize_string(string)
        string.gsub(/_([a-z])/) { $1.upcase }
      end
    end
  end
end
