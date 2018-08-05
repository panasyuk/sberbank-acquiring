require 'openssl'

module Sberbank
  module Acquiring
    class SymmetricKeyChecksumValidator
      DIGEST_CLASS = OpenSSL::Digest::SHA256

      def initialize(key, digest = DIGEST_CLASS.new)
        @key = key
        @digest = digest
      end

      def validate(checksum, params = {})
        checksum == calculate_checksum(generate_digest_data(params))
      end

      def calculate_checksum(data)
        OpenSSL::HMAC.hexdigest(@digest, @key, data).upcase!
      end

      private

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
