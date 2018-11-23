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
    request = described_class.new(path: Object.new, credentials: build_credentials, params: Object.new)
    refute request.test
  end

  def test_test
    expected_test = Object.new
    request = build_default_request(test: expected_test)

    assert_equal expected_test, request.test
  end

  def test_host_default
    request = described_class.new(path: Object.new, credentials: build_credentials, params: Object.new)
    assert_equal Sberbank::Acquiring::Request::PRODUCTION_HOST, request.host
  end

  def test_test_host
    request = described_class.new(path: Object.new, credentials: build_credentials, params: Object.new, test: true)
    assert_equal Sberbank::Acquiring::Request::TEST_HOST, request.host
  end

  def test_host
    expected_host = Object.new
    request = build_default_request(host: expected_host)

    assert_equal expected_host, request.host
  end

  def test_build_uri
    expected_path   = 'somePath'
    expected_host   = 'some-host'
    request = build_default_request(path: expected_path, host: expected_host)

    request.stub :build_query, nil do
      assert_equal 'https://some-host/payment/rest/somePath.do', request.build_uri.to_s
    end
  end

  def test_build_query_with_token_credentials
    request = build_default_request(credentials: build_token_credentials, params: { some_param: 'some value' })
    assert_equal 'someParam=some+value&token=token', request.build_query
  end

  def test_build_query_with_username_and_password_credentials
    request = build_default_request(credentials: build_username_and_password_credentials, params: { some_param: 'some value' })
    assert_equal 'someParam=some+value&userName=username&password=password', request.build_query
  end

  def test_build_query_redefines_and_filters_wrong_credentials_params
    request =
      build_default_request(
      credentials: build_username_and_password_credentials,
      params: {
        some_param:           'some value',
        password:             'wrong_password',
        username:             'wrong_username',
        userName:             'wrong_username',
        'userName'         => 'wrong_username',
        'username'         => 'wrong_username',
        'password'         => 'wrong_password',
        'token'            => 'wrong_token',
        'any_other_string' => 'another value'
      })
    actual_query = request.build_query

    refute_includes actual_query, 'wrong_password'
    refute_includes actual_query, 'wrong_username'
    refute_includes actual_query, 'wrong_token'
    refute_includes actual_query, 'any_other_string'
  end

  def test_perform
    request =
      build_default_request(
      host: Sberbank::Acquiring::Request::PRODUCTION_HOST,
      path: 'register',
      params: {
        order_number: 'order#1',
        amount: 12345,
        return_url: 'https://return.example.com/sberbank_payments/success',
        json_params: { email: 'user@example.com' }
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
        order_number: 'order#1',
        amount: 12345,
        return_url: 'https://return.example.com/sberbank_payments/success',
        json_params: { email: 'user@example.com' }
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
        order_number: 'order#1',
        amount: 12345,
        return_url: 'https://return.example.com/sberbank_payments/success',
        json_params: { email: 'user@example.com' }
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

  def build_token_credentials(token: 'token')
    Sberbank::Acquiring::Credentials.new(token: 'token')
  end
  alias build_credentials build_token_credentials

  def build_username_and_password_credentials(username: 'username', password: 'password')
    Sberbank::Acquiring::Credentials.new(username: username, password: password)
  end

  def build_default_request(path: Object.new, credentials: build_credentials, params: Object.new, test: Object.new, host: Object.new)
    described_class.new(path: path, credentials: credentials, params: params, test: test, host: host)
  end
end
