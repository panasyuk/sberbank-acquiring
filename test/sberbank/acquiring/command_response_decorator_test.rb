# frozen_string_literal: true

require 'test_helper'

module Sberbank
  module Acquiring
    class CommandResponseDecoratorTest < Minitest::Test
      def test_response
        expected_response = Object.new

        decorator = described_class.new(expected_response)
        assert expected_response, decorator.response
      end

      def test_data
        expected_data = Object.new
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, expected_data)

        assert_equal expected_data, described_class.new(response_mock).data

        response_mock.verify
      end

      def test_request
        expected_request = Object.new
        response_mock = Minitest::Mock.new
        response_mock.expect(:request, expected_request)

        assert_equal expected_request, described_class.new(response_mock).request

        response_mock.verify
      end

      def test_http_response
        expected_http_response = Object.new
        response_mock = Minitest::Mock.new
        response_mock.expect(:http_response, expected_http_response)

        assert_equal expected_http_response, described_class.new(response_mock).http_response

        response_mock.verify
      end

      def test_http
        expected_http = Object.new
        response_mock = Minitest::Mock.new
        response_mock.expect(:http, expected_http)

        assert_equal expected_http, described_class.new(response_mock).http

        response_mock.verify
      end

      def test_error_returns_true_if_data_is_nil
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, nil) do
          assert described_class.new(response_mock).error?
          refute described_class.new(response_mock).success?
        end
      end

      def test_error_returns_false_if_data_has_no_error_code_key
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, foo: :bar) do
          refute described_class.new(response_mock).error?
          assert described_class.new(response_mock).success?
        end
      end

      def test_error_returns_false_if_data_has_zero_code_key
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, 'errorCode' => 0) do
          refute described_class.new(response_mock).error?
          assert described_class.new(response_mock).success?
        end
      end

      def test_error_returns_true_if_data_has_positive_error_code
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, 'errorCode' => 1) do
          assert described_class.new(response_mock).error?
          refute described_class.new(response_mock).success?
        end
      end

      def test_missing_method_call_retrieves_key_from_data_hash
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, 'garbageIn' => 'garbageOut') do
          assert_equal 'garbageOut', described_class.new(response_mock).garbage_in
        end
      end

      def test_missing_method_raises_no_method_error_if_data_key_is_missing
        response_mock = Minitest::Mock.new
        response_mock.expect(:data, 'garbageIn' => 'garbageOut') do
          assert_raises NoMethodError do
            described_class.new(response_mock).garbage_out
          end
        end
      end

      private

      def described_class
        CommandResponseDecorator
      end
    end
  end
end
