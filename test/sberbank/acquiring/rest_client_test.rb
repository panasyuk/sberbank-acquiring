require "test_helper"

class Sberbank::Acquiring::RestClientTest < Minitest::Test
  def setup
    @subject = Sberbank::Acquiring::RestClient.new(username: 'username', password: 'password')
  end

  def test_get_makes_request
    stub_sberbank_rest_request(action: 'actionName', params: { 'foo' => 'bar' })
    @subject.get('actionName', { 'foo' => 'bar' })
  end

  def test_raises_parsing_error_on_invalid_response_body
    stub_sberbank_rest_request(action: 'actionName', response_body: '<invalid json>')

    assert_raises JSON::ParserError do
      @subject.get('actionName')
    end
  end

  private

  def stub_sberbank_rest_request(action:, username: 'username', password: 'password', params: {}, response_body: '{}')
    stub_request(:get, "https://3dsec.sberbank.ru/payment/rest/#{action}.do").
      with(query: params.merge({ 'userName' => username, 'password' => password})).
      to_return(body: response_body)
  end
end
