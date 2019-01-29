# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::AbstractChecksumValidatorTest < Minitest::Test
  def setup
    @concrete_class = Class.new(Sberbank::Acquiring::AbstractChecksumValidator)
    @subject = @concrete_class.new(:key)
  end

  def test_valid_returns_false_if_checksum_is_valid
    expected_checksum = Object.new
    expected_result = Object.new
    params = { 'checksum' => expected_checksum, 'foo' => 'bar' }

    @subject.stub(:validate, expected_result, [expected_result, { 'foo' => 'bar' }]) do
      assert_equal expected_result, @subject.valid?(params)
    end
  end
end
