require File.expand_path("test_helper", __dir__)

require 'kasefet/flat_kv'
require 'fileutils'

class FlatKVTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @flatkv = Kasefet::FlatKV.new(root: @tmpdir)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_sets_extension_intelligently
    @flatkv.extension = "value"
    assert_equal ".value", @flatkv.extension
    @flatkv.extension = ".other"
    assert_equal ".other", @flatkv.extension
  end

  def test_sets_and_reads_values
    @flatkv["foobar"] = "hello, world"
    stored_value = @flatkv["foobar"]
    assert_equal "hello, world", stored_value
  end

  def test_stores_history_of_values
    @flatkv["myname"] = "jon"
    @flatkv["myname"] = "jon jacob"
    @flatkv["myname"] = "jon jacob jingleheimer"
    key_dir = @flatkv.dir_for_key("myname")
    value_files = Dir.glob(key_dir + "*")
    assert_equal 3, value_files.size
    assert_equal "jon jacob jingleheimer", @flatkv["myname"]
  end

  def test_read_empty_values
    value = @flatkv["foobar"]
    assert_nil value
  end
end
