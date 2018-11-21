# frozen_string_literal: true

module Sberbank
  module Acquiring
    class Credentials
      def initialize(data)
        validate_data!(data)

        data_clone = {}
        data.each { |k, v| data_clone[k] = v.dup.freeze }
        data_clone.freeze

        @data_proc = proc { data_clone }
      end

      def to_h
        @data_proc.call
      end

      private

      def validate_data!(data)
        unless data.is_a?(Hash)
          raise ArgumentError, 'Expected initialization attribute to be Hash'
        end

        unless data.keys == %i(username password) || data.keys == %i(token)
          raise ArgumentError, 'Expected keys are: :username and :password or :token'
        end
      end
    end
  end
end
