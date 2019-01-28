# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::SymmetricKeyChecksumValidatorTest < Minitest::Test
  def setup
    @digest = OpenSSL::Digest::SHA256.new
    @key = SecureRandom.hex
    @subject = Sberbank::Acquiring::SymmetricKeyChecksumValidator.new(@key)
    @example_params = { 'foo' => 'bar', bar: 'baz' }
    @example_data = 'bar;baz;foo;bar;'
    @example_checksum =
      OpenSSL::HMAC.hexdigest(@digest, @key, @example_data).upcase!
  end

  def test_validate_returns_false_if_checksum_is_invalid
    wrong_checksum = SecureRandom.hex.upcase!
    refute @subject.validate(wrong_checksum, @example_params)
  end

  def test_validate_returns_true_if_checksum_is_valid
    assert @subject.validate(@example_checksum, @example_params)
  end

  def test_calculate_checksum_returns_sha256_hexdigest_in_upper_case
    assert_equal OpenSSL::HMAC.hexdigest(@digest, @key, @example_data).upcase!,
                 @subject.calculate_checksum(@example_data)
  end
end
