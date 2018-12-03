# frozen_string_literal: true

require 'test_helper'

module Sberbank
  module Acquiring
    class ResponseTest < Minitest::Test
      def test_http_response
        http_response_mock = build_http_response_mock
        response = build_response(http_response: http_response_mock)

        assert_equal http_response_mock.__id__, response.http_response.__id__
        assert_equal http_response_mock.__id__, response.http.__id__
      end

      def test_request
        expected_request = Object.new
        response = build_response(request: expected_request)

        assert_equal expected_request, response.request
      end

      def test_data_when_http_response_is_valid_json
        expected_data = { 'foo' => 'bar', 'bar' => 'baz' }
        http_response_mock = build_http_response_mock(body: expected_data.to_json)
        response = build_response(http_response: http_response_mock)

        assert_equal expected_data, response.data
      end

      def test_data_when_http_response_is_not_valid_json
        http_response_mock = build_http_response_mock(body: 'invalid JSON')
        response = build_response(http_response: http_response_mock)

        assert_nil response.data
      end

      private

      def described_class
        Response
      end

      def build_http_response_mock(body: '', status: '200')
        mock = Minitest::Mock.new
        mock.expect(:body, body)
        mock.expect(:status, status)

        mock
      end

      def build_response(http_response: build_http_response_mock, request: Object.new)
        described_class.new(http_response: http_response, request: request)
      end
    end
  end
end