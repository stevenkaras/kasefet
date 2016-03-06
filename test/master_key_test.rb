require File.expand_path("test_helper", __dir__)

require "kasefet/master_key"
require "fileutils"
require "pathname"
require "securerandom"

class MasterKeyTest < Minitest::Test
  def setup
    @tmpdir = Pathname.new(Dir.mktmpdir)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_roundtrip
    master_key = Kasefet::MasterKey.new(@tmpdir + "key")
    second_instance = Kasefet::MasterKey.new(@tmpdir + "key")
    assert_equal master_key.key, second_instance.key
  end

  def test_passphrase_roundtrip
    master_key = Kasefet::MasterKey.new(@tmpdir + "key", passphrase: "foobar")
    second_instance = Kasefet::MasterKey.new(@tmpdir + "key", passphrase: "foobar")
    assert_equal master_key.key, second_instance.key
  end

  def test_keyfile_roundtrip
    File.binwrite(@tmpdir + "keyfile", SecureRandom.random_bytes(Kasefet::MasterKey::CipherKeyLength))
    master_key = Kasefet::MasterKey.new(@tmpdir + "key", keyfile: @tmpdir + "keyfile")
    second_instance = Kasefet::MasterKey.new(@tmpdir + "key", keyfile: @tmpdir + "keyfile")
    assert_equal master_key.key, second_instance.key
  end
end