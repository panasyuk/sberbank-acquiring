# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::CredentialsTest < Minitest::Test
  def test_raises_argument_error_if_initalized_with_no_arguments
    assert_raises ArgumentError do
      Sberbank::Acquiring::Credentials.new
    end
  end

  def test_raises_argument_error_if_initalized_with_wrong_keys
    assert_raises ArgumentError do
      Sberbank::Acquiring::Credentials.new(username: Object.new, password: Object.new, wrong_key: Object.new)
    end
  end

  def test_can_be_initialized_with_username_and_password
    build_with_username_and_password(username: Object.new, password: Object.new)
  end

  def test_can_be_initialized_with_token
    build_with_token(token: Object.new)
  end

  def test_does_not_expose_token
    refute_respond_to(build_with_token, :token)
  end

  def test_does_not_expose_username_or_password
    credentials = build_with_username_and_password

    refute_respond_to(credentials, :username)
    refute_respond_to(credentials, :password)
  end

  def test_does_not_expose_token_in_inspect_string
    expected_token = '/\oo/\\'

    credentials = build_with_token(token: expected_token)
    refute_includes credentials.inspect, 'token'
    refute_includes credentials.inspect, expected_token
  end

  def test_does_not_username_or_password_in_inspect_string
    expected_username = '()()():|'
    expected_password = '{-_-}'
    credentials = build_with_username_and_password(username: expected_username, password: expected_password)

    refute_includes credentials.inspect, 'username'
    refute_includes credentials.inspect, expected_username
    refute_includes credentials.inspect, 'password'
    refute_includes credentials.inspect, expected_password
  end

  def test_to_h_with_token
    expected_token = 'expected_token'
    credentials = build_with_token(token: expected_token)

    assert credentials.to_h == { token: expected_token }
  end

  def test_does_not_freeze_attributes_on_initialization
    attributes = { token: Object.new }
    Sberbank::Acquiring::Credentials.new(attributes)

    refute attributes.frozen?
    refute attributes[:token].frozen?
  end

  def test_to_h_with_token_is_frozen
    assert build_with_token.to_h.frozen?
  end

  def test_to_h_with_token_has_frozen_token
    assert build_with_token.to_h[:token].frozen?
  end

  def test_to_h_with_token_is_the_same
    credentials = build_with_token
    assert_equal credentials.to_h.__id__, credentials.to_h.__id__
  end

  def test_to_h_with_username_and_password
    expected_username = 'expected_username'
    expected_password = 'expected_password'
    credentials = build_with_username_and_password(username: expected_username, password: expected_password)

    assert credentials.to_h == { username: expected_username, password: expected_password }
  end

  def test_to_h_with_username_and_password_is_frozen
    assert build_with_username_and_password.to_h.frozen?
  end

  def test_to_h_with_token_has_frozen_username_and_password
    assert build_with_username_and_password.to_h[:username].frozen?
    assert build_with_username_and_password.to_h[:password].frozen?
  end

  def test_to_h_with_username_and_password_is_the_same
    credentials = build_with_username_and_password
    assert_equal credentials.to_h.__id__, credentials.to_h.__id__
  end

  def build_with_token(token: Object.new)
    Sberbank::Acquiring::Credentials.new(token: token)
  end

  def build_with_username_and_password(username: Object.new, password: Object.new)
    Sberbank::Acquiring::Credentials.new(username: username, password: password)
  end
end
