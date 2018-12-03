# frozen_string_literal: true

module Sberbank
  module Acquiring
    class CommandParametersConvertor
      attr_reader :default_params

      def initialize(default_params = {})
        @default_params = default_params
      end

      def convert(params)
        jsonify_hash_values(camelize_keys(params).merge!(default_params))
      end

      def camelize_keys(hash)
        result = {}

        hash.each do |k, v|
          result[camelize_string(k.to_s)] = v.is_a?(Hash) && camelize_keys(v) || v
        end

        result
      end

      def jsonify_hash_values(hash)
        result = hash.dup

        result.each do |k, v|
          result[k] = v.is_a?(Hash) && v.to_json || v
        end

        result
      end

      private

      def camelize_string(string)
        string.gsub(/_([a-z])/) { $1.upcase }
      end
    end
  end
end
