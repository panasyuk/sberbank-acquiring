require "test_helper"

class Sberbank::Acquiring::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sberbank::Acquiring::Client::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
