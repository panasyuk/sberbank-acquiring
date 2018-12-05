# frozen_string_literal: true

module Sberbank
  module Acquiring
    class CommandParametersConvertor
      attr_reader :default_params

      def initialize(default_params = {})
        @default_params = default_params
      end

      def convert(params)
        jsonify_hash_values(camelize(params).merge!(default_params))
      end

      def camelize(params)
        case params
        when Hash then camelize_hash(params)
        when Enumerable then camelize_enumerable(params)
        else params
        end
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

      def camelize_hash(hash)
        result = {}
        hash.each { |k, v| result[camelize_string(k.to_s)] = camelize(v) }
        result
      end

      def camelize_enumerable(enumerable)
        enumerable.map { |e| camelize(e) }
      end
    end
  end
end
