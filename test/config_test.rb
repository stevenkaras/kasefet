require File.expand_path("test_helper", __dir__)

require "kasefet/config"
require "fileutils"

class ConfigTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @config = Kasefet::Config.new(@tmpdir + "global.json")
    @config.load
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_elegant_default
    value = @config["something"] = 1
    assert_equal value, @config["something"]
    assert_equal 1, value

    @config["foo"] ||= 2
    assert_equal 2, @config["foo"]

    @config["foo"] ||= 3
    assert_equal 2, @config["foo"]

    @config["deeply.nested.value"] = 4
    assert_equal 4, @config["deeply.nested.value"]
    @config["deeply.nested.value"] ||= 5
    assert_equal 4, @config["deeply.nested.value"]

    @config["deeply.nested.othervalue"] ||= 6
    assert_equal 6, @config["deeply.nested.othervalue"]
    @config["deeply.nested.othervalue"] ||= 7
    assert_equal 6, @config["deeply.nested.othervalue"]
  end

  def test_roundtrip
    @config["foo"] = 1
    assert_equal 1, @config["foo"]

    @config["bar.baz"] = 2
    assert_equal 2, @config["bar.baz"]
  end

  def test_json_roundtrip
    @config.file = @tmpdir + "global.json"
    do_roundtrip_test
  end

  def test_yaml_roundtrip
    @config.file = @tmpdir + "global.yaml"
    do_roundtrip_test
  end

  def test_kv_roundtrip
    @config.file = @tmpdir + "global.kv"
    do_roundtrip_test
  end

  def do_roundtrip_test
    @config["foo"] = 1
    @config["bar.baz"] = 2
    @config["array"] = [1, 2]
    @config.save

    other_config = Kasefet::Config.new(@config.file)
    other_config.load
    assert_equal @config["foo"], other_config["foo"]
    assert_equal @config["bar.baz"], other_config["bar.baz"]
    assert_equal @config["array"], other_config["array"]
  end

  def test_flatten_hash
    flattened = @config.flatten_hash({ "foo" => 1 })
    assert_equal({ "foo" => 1 }, flattened)

    flattened = @config.flatten_hash({ "foo" => 1, "bar" => { "baz" => 2, "quux" => 3 } })
    assert_equal({ "foo" => 1, "bar.baz" => 2, "bar.quux" => 3 }, flattened)
  end
end
