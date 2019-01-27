# frozen_string_literal: true

module Sberbank
  module Acquiring
    class AsymmetricKeyChecksumValidator < AbstractChecksumValidator
      def validate(checksum, params = {})
        certificate.public_key.verify(
          @digest,
          [checksum].pack('H*'),
          generate_digest_data(params)
        )
      end

      private

      def certificate
        @certificate ||= OpenSSL::X509::Certificate.new(@key)
      end

      def digest_class
        OpenSSL::Digest::SHA512
      end
    end
  end
end
