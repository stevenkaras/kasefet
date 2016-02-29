require File.expand_path("test_helper", __dir__)

class KasefetTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Kasefet::VERSION
  end
end
