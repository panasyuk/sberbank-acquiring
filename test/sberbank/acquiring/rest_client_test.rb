require 'test_helper'

class Sberbank::Acquiring::RestClientTest < Minitest::Test
  def test_get_makes_request
    stub_test_request(action: 'actionName', params: { 'foo' => 'bar' })

    client = build_subject_instance(test: true)
    client.get('actionName', { 'foo' => 'bar' })
  end

  def test_raises_parsing_error_on_invalid_response_body
    stub_test_request(action: 'actionName', response_body: '<invalid json>')

    client = build_subject_instance(test: true)
    assert_raises JSON::ParserError do
      client.get('actionName')
    end
  end

  def test_get_makes_request
    stub_production_request(action: 'actionName', params: { 'foo' => 'bar' })

    client = build_subject_instance(test: false)
    client.get('actionName', { 'foo' => 'bar' })
  end

  def test_raises_parsing_error_on_invalid_response_body
    stub_production_request(action: 'actionName', response_body: '<invalid json>')

    client = build_subject_instance(test: false)
    assert_raises JSON::ParserError do
      client.get('actionName')
    end
  end

  private

  def stub_production_request(action:, username: 'username', password: 'password', params: {}, response_body: '{}')
    stub_rest_request(
      url: "https://securepayments.sberbank.ru/payment/rest/#{action}.do",
      username: username,
      password: password,
      params: params,
      response_body: response_body
    )
  end

  def stub_test_request(action:, username: 'username', password: 'password', params: {}, response_body: '{}')
    stub_rest_request(
      url: "https://3dsec.sberbank.ru/payment/rest/#{action}.do",
      username: username,
      password: password,
      params: params,
      response_body: response_body
    )
  end

  def stub_rest_request(url:, username: 'username', password: 'password', params: {}, response_body: '{}')
    stub_request(:get, url).
      with(query: params.merge({ 'userName' => username, 'password' => password})).
      to_return(body: response_body)
  end

  def build_subject_instance(test: false)
    Sberbank::Acquiring::RestClient.new(username: 'username', password: 'password', test: test)
  end
end
