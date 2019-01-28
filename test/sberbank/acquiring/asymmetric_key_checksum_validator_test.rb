# frozen_string_literal: true

require 'test_helper'

class Sberbank::Acquiring::AsymmetricKeyChecksumValidatorTest < Minitest::Test
  TEST_CERTIFICATE = <<-PEM.gsub(/^ */, '').freeze
    -----BEGIN CERTIFICATE-----
    MIIDhjCCAm4CCQDfa2PU2JeB/zANBgkqhkiG9w0BAQsFADCBhDELMAkGA1UEBhMC
    UlUxGzAZBgNVBAgTEktyYXNub3lhcnNraXktS3JheTEUMBIGA1UEBxMLS3Jhc25v
    eWFyc2sxKDAmBgNVBAoTH0lQIFBhbmFzeXVrIEFsZWtzYW5kciBJdmFub3ZpY2gx
    GDAWBgkqhkiG9w0BCQEWCWFAcGFuYS5zdTAeFw0xOTAxMjcxMzI2MTRaFw0yMDAx
    MjcxMzI2MTRaMIGEMQswCQYDVQQGEwJSVTEbMBkGA1UECBMSS3Jhc25veWFyc2tp
    eS1LcmF5MRQwEgYDVQQHEwtLcmFzbm95YXJzazEoMCYGA1UEChMfSVAgUGFuYXN5
    dWsgQWxla3NhbmRyIEl2YW5vdmljaDEYMBYGCSqGSIb3DQEJARYJYUBwYW5hLnN1
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA10+aOZ4eHptV6am48Y53
    e/7Nb1WWxxvGBWq8WhDTGKttU2bc/Bd7KqUxPE/ZX2tWQQkxnPXt20ByMbKa6fP9
    Dx2jHo8QLwJ0yec1rBmjh8GMaN2ehD74HunNn0pllfwKvF7+pfTtXF0tNdgu88Ei
    cv6UZ+7Kt9LnC1afUqjEyI9X/5DKuH+cTb/K9JxfT5hUjApnDO5JvihJkaBymBTu
    aYQoE0uY4q7xUOhwX4z4hOZRBkyQIBDbVQS+1zIWAwLIeePTsyiaX1WbGFVxiQ4+
    vel3QZZ/5Du0y2EuWRBwvo6Octljx2tzsqUel1DNPiSTLGpOwpZEWY72HaBfLN+c
    fwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBkVvQU9mLhK+4cCBbo/g3pi/f9VgYG
    ASAzSqgEiOVb9nyF8kL1xjC6FnSU86EJm7JHyhAEZQYvIDpIzEYDdg3MiEd6/LT2
    4O4xTH8ACgjEQF5K/RxZzWqdaQ1fB1VFxeAPWIZIlypFafPxEAOFnzzh0tvfvcev
    GD+qJy6bXqSgx8/qqKTppPzBqWcBzTsyLAMTrhY2R6ki8htacQlPtk8mRczgoD7T
    bL+hczNJXrUyj5ASM8kwzxAfSkzT6D0ss3rqT4KARyMjXA39vmdvUfw+ysL/3s2O
    Qkas1RVpcEGVRJ5eSGyuRa/bSNx7hTI0CHhM8xlIHCFQu4bsb1cqKnTr
    -----END CERTIFICATE-----
  PEM

  TEST_PRIVATE_KEY = <<-PEM.gsub(/^ */, '').freeze
    -----BEGIN RSA PRIVATE KEY-----
    MIIEogIBAAKCAQEA10+aOZ4eHptV6am48Y53e/7Nb1WWxxvGBWq8WhDTGKttU2bc
    /Bd7KqUxPE/ZX2tWQQkxnPXt20ByMbKa6fP9Dx2jHo8QLwJ0yec1rBmjh8GMaN2e
    hD74HunNn0pllfwKvF7+pfTtXF0tNdgu88Eicv6UZ+7Kt9LnC1afUqjEyI9X/5DK
    uH+cTb/K9JxfT5hUjApnDO5JvihJkaBymBTuaYQoE0uY4q7xUOhwX4z4hOZRBkyQ
    IBDbVQS+1zIWAwLIeePTsyiaX1WbGFVxiQ4+vel3QZZ/5Du0y2EuWRBwvo6Octlj
    x2tzsqUel1DNPiSTLGpOwpZEWY72HaBfLN+cfwIDAQABAoIBAB2nRvRchIVum1x9
    FY2fM3GOXDjTLtrpRlKEqsA0xP4Gzh3IcvL9QOdUrP1DegqcO9rlK0IU1Nd3fsK9
    eHx0MAwe5tJUncP7sJ4GC+xR86XE0FO5AhXwnjeTt9ASbP9FIS1kX+n3W6F2670Y
    sw67MMVproLJ7n12vH9hRLwbpk6Avs8uWF2LgqUJQDg/PAQtwBseedjfZiiQuJte
    +cq1FCRWhAiC/8+Gw1Tih9OMdBEYcetvYiEJGfQKUjojNU7b6n/4JW8W2ah3m9oG
    powmYGhyb9oqgi19nIFqfL1fUadL6WT/7Hs3HN0vprGZLIxQ+8QVoHgBcUKgRT/+
    +EZZArECgYEA7csO/2dfkX35OcDTG5NnTaXN+vFNqNTPAYpeWz4+quYpqx87FqY/
    c31dYsszJL4T21IHhIuyrCSCAQlhmzS+0uFemfkBQVD8AtAF++nWBWF0MoUxswEP
    n8yzC/p2Oe9aluczpFC9Ld2UCvCbzQxQ+CfRJ9ZsnQULW3Wck6t2Dn0CgYEA58vf
    ktJnrjiMupGue6A7kdnafM21atqEwZZjIQDPi8wc7lFKh38gu5wgclIlFXodiO/2
    1XO3U/i+AvBRtwu4faAo82jqWOe9tJk+JF54XT6nSp5DNZoPRAwnEUyecHs0oMl/
    PxAFHdUqYSiq9M6vPhJ01RQoB4ioXY5P6YhL26sCgYBQNYA3kkzgLJfWbT5IPO5J
    eLYEAUTqv+2bXWr6aAKHbt97QyuRNj6M3CqV2mjD6gGUpxS2FtEL07yuUNXFnoMH
    atGYKi/MMl7vK+/4yyVP51FkgR0EfkUg59E1JySd4iiyYgY/VKSbRfRbxFEpVxAw
    xG1+fItiY4MzNHa+MMW/mQKBgDvUb7zh+kkJ56kweS0Hyth2tuKH5k/SX3noa2XV
    Y7zdzonlCau3sKc8QVPAyDmm74CtD7VAzQ0roz/27+CjcddbQ7awWezgxCKde2C/
    0amfxmaIOyjWvyH9UQgyEqNN6eOmnuWUKP3uS6YQbTALOUh4Uxe8wChRqcOcPBw3
    Rf1JAoGAFYRQ0lSOrDgC3B5IXCTv4ru3922f4k8r6IVAghyTBoklvbf5x/ASvsml
    0zYRtOEBj6xkY9+rG1WRha5Ed0j/XNpjyzO7DsDm6qCvNe8xfqhsQ2RnZ+/BiLZp
    TnFsR6HFlYEn2EN6iw3w1Q7qDkT9r6YM35bpLibqsRQS62bZhdQ=
    -----END RSA PRIVATE KEY-----
  PEM

  def setup
    @digest = OpenSSL::Digest::SHA512.new
    @subject = Sberbank::Acquiring::AsymmetricKeyChecksumValidator.new(TEST_CERTIFICATE)
    @example_params = { 'foo' => 'bar', bar: 'baz' }
    @example_data = 'bar;baz;foo;bar;'
  end

  def test_validate_returns_false_if_checksum_is_valid
    wrong_checksum = SecureRandom.hex.upcase!
    refute @subject.validate(wrong_checksum, @example_params)
  end

  def test_validate_returns_true_if_checksum_is_valid
    expected_checksum =
      OpenSSL::PKey::RSA.
      new(TEST_PRIVATE_KEY).
      sign(@digest, @example_data).
      unpack('H*').
      first.
      upcase

    assert @subject.validate(expected_checksum, @example_params)
  end
end
