# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::RequestTest < Minitest::Test
  def test_path
    expected_path = Object.new
    request = build_default_request(path: expected_path)

    assert_equal expected_path, request.path
  end

  def test_params
    expected_params = Object.new
    request = build_default_request(params: expected_params)

    assert_equal expected_params, request.params
  end

  def test_test_default
    request = described_class.new(path: Object.new, params: Object.new)
    refute request.test
  end

  def test_test
    expected_test = Object.new
    request = build_default_request(test: expected_test)

    assert_equal expected_test, request.test
  end

  def test_host_default
    request = described_class.new(path: Object.new, params: Object.new)
    assert_equal Sberbank::Acquiring::Request::PRODUCTION_HOST, request.host
  end

  def test_test_host
    request = described_class.new(path: Object.new, params: Object.new, test: true)
    assert_equal Sberbank::Acquiring::Request::TEST_HOST, request.host
  end

  def test_host
    expected_host = Object.new
    request = build_default_request(host: expected_host)

    assert_equal expected_host, request.host
  end

  def test_perform
    request =
      build_default_request(
      host: Sberbank::Acquiring::Request::PRODUCTION_HOST,
      path: 'register',
      params: {
        orderNumber: 'order#1',
        amount: 12345,
        returnUrl: 'https://return.example.com/sberbank_payments/success',
        jsonParams: '{"email":"user@example.com"}',
        token: 'token'
      })

    stub_request(:get, 'https://securepayments.sberbank.ru/payment/rest/register.do?amount=12345&jsonParams=%7B%22email%22:%22user@example.com%22%7D&orderNumber=order%231&returnUrl=https://return.example.com/sberbank_payments/success&token=token')
    actual_return_value = request.perform

    assert_kind_of Sberbank::Acquiring::Response, actual_return_value
    assert_equal request.__id__, actual_return_value.request.__id__
  end

  def test_perform_returns_nil_on_socket_error
    request =
      build_default_request(
      host: Sberbank::Acquiring::Request::PRODUCTION_HOST,
      path: 'register',
      params: {
        orderNumber: 'order#1',
        amount: 12345,
        returnUrl: 'https://return.example.com/sberbank_payments/success',
        jsonParams: '{"email":"user@example.com"}'
      })

    # TODO: make Net::HTTP#request fail with SocketError instead of Net::HTTP.start
    Net::HTTP.stub :start, proc { fail SocketError } do
      assert_nil request.perform
    end
  end

  def test_perform_returns_nil_on_timeout
    request =
      build_default_request(
      host: Sberbank::Acquiring::Request::PRODUCTION_HOST,
      path: 'register',
      params: {
        orderNumber: 'order#1',
        amount: 12345,
        returnUrl: 'https://return.example.com/sberbank_payments/success',
        jsonParams: '{"email":"user@example.com"}'
      })

    # TODO: make Net::HTTP#request fail with Errno::ETIMEDOUT instead of Net::HTTP.start
    Net::HTTP.stub :start, proc { fail Errno::ETIMEDOUT } do
      assert_nil request.perform
    end
  end

  private

  def described_class
    Sberbank::Acquiring::Request
  end

  def build_default_request(path: Object.new, params: Object.new, test: Object.new, host: Object.new)
    described_class.new(path: path, params: params, test: test, host: host)
  end
end
