# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::ClientTest < Minitest::Test
  def test_initialize_builds_credentials_with_username_and_password
    expected_username = Object.new
    expected_password = Object.new

    client = Sberbank::Acquiring::Client.new(username: expected_username, password: expected_password)

    credentials = client.instance_variable_get(:@credentials)
    assert_kind_of Sberbank::Acquiring::Credentials, credentials
    assert credentials.to_h, { username: expected_username, password: expected_password }
  end

  def test_initialize_builds_credentials_with_token
    expected_token = Object.new

    client = Sberbank::Acquiring::Client.new(token: expected_token)

    credentials = client.instance_variable_get(:@credentials)
    assert_kind_of Sberbank::Acquiring::Credentials, credentials
    assert credentials.to_h, { token: expected_token }
  end

  def test_test_default
    client = Sberbank::Acquiring::Client.new(token: Object.new)

    refute client.test?
    refute client.test
  end

  def test_test
    client = Sberbank::Acquiring::Client.new(token: Object.new, test: true)
    assert client.test?
    assert client.test
  end
end
