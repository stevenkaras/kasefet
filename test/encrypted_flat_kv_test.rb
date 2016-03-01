require File.expand_path("test_helper", __dir__)

require 'kasefet/encrypted_flat_kv'
require 'fileutils'

class EncryptedFlatKVTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @cipher = OpenSSL::Cipher.new("aes-256-cbc")
    @cipher_key = @cipher.random_key
    @cipher_iv = @cipher.random_iv
    @flatkv = Kasefet::EncryptedFlatKV.new(root: @tmpdir, cipher_key: @cipher_key, cipher_iv: @cipher_iv, cipher: @cipher)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
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

  def test_stores_encrypted_values
    @flatkv["foobar"] = "hello, world"
    value_file = @flatkv.file_for_key("foobar")
    refute_equal File.binread(value_file), @flatkv["foobar"]
  end
end
