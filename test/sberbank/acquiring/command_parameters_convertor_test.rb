# frozen_string_literal: true

require 'test_helper'

module Sberbank
  module Acquiring
    class CommandParametersConvertorTest < Minitest::Test
      def test_default_params
        expected_default_params = Object.new

        convertor = described_class.new(expected_default_params)
        assert_equal expected_default_params, convertor.default_params
      end

      def test_default_default_params
        convertor = described_class.new

        assert_kind_of Hash, convertor.default_params
        assert_empty convertor.default_params
      end

      def test_jsonify_hash_values
        expected_result = { foo: '{"foo":{"bar":"baz"}}' }
        actual_result = described_class.new.jsonify_hash_values(foo: { foo: { bar: :baz } })

        assert_equal expected_result, actual_result
      end

      def test_camelize_keys
        expected_result = { 'garbageIn' => { 'garbageOut' => true } }
        actual_result = described_class.new.camelize_keys(garbage_in: { garbage_out: true })

        assert_equal expected_result, actual_result
      end

      def test_convert
        expected_result = { 'foo' => 'bar', 'garbageIn' => '{"garbageOut":true}', 'anotherKey' => 'value' }
        actual_result =
          described_class.
          new('garbageIn' => { 'garbageOut' => true }, 'anotherKey' => 'value').
          convert(foo: 'bar', garbage_in: :garbage_out)

        assert_equal expected_result, actual_result
      end

      private

      def described_class
        CommandParametersConvertor
      end
    end
  end
end
