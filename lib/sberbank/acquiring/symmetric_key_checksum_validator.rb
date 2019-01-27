# frozen_string_literal: true

module Sberbank
  module Acquiring
    class SymmetricKeyChecksumValidator < AbstractChecksumValidator
      def validate(checksum, params = {})
        checksum == calculate_checksum(generate_digest_data(params))
      end

      def calculate_checksum(data)
        OpenSSL::HMAC.hexdigest(@digest, @key, data).upcase!
      end
    end
  end
end
