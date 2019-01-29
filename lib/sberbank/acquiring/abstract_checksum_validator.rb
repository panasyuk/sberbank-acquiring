# frozen_string_literal: true

module Sberbank
  module Acquiring
    class AbstractChecksumValidator
      def initialize(key, digest = digest_class.new)
        @key = key
        @digest = digest
      end

      def validate(checksum, params)
        raise NotImplementedError
      end

      def valid?(params)
        params_to_validate = params.dup
        validate(params_to_validate.delete('checksum'), params_to_validate)
      end

      private

      def digest_class
        OpenSSL::Digest::SHA256
      end

      def generate_digest_data(params)
        params.
          keys.
          sort { |a, b| a.to_s <=> b.to_s }.
          map { |param_key| "#{param_key};#{params[param_key]};" }.
          join
      end
    end
  end
end
