require File.expand_path("test_helper", __dir__)

require "kasefet/flat_kv"
require "kasefet/encrypted_flat_kv"
require "kasefet/indexed_flat_kv"
require "fileutils"

class IndexedFlatKVTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @flatkv = Kasefet::FlatKV.new(root: @tmpdir)
    @index = Kasefet::IndexedFlatKV.new(flat_kv: @flatkv)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_rebuild
    @flatkv["foo"] = "1"
    @flatkv["bar"] = "2"
    @flatkv["baz"] = "3"

    @index.rebuild_index
    assert @index.has_key?("foo")
    assert @index.has_key?("bar")
    assert @index.has_key?("baz")
  end

  def test_no_rebuild
    @index["foo"] = "1"

    assert @index.has_key?("foo")
  end

  def test_each_keys
    @flatkv["foo"] = "1"
    @flatkv["bar"] = "1"

    @index.rebuild_index
    assert_equal ["bar", "foo"].sort, @index.each_keys.to_a.sort
  end

  def test_with_encrypted_flat_kv
    @cipher = OpenSSL::Cipher.new("aes-256-gcm")
    @cipher_key = @cipher.random_key
    @encrypted_flat_kv = Kasefet::EncryptedFlatKV.new(root: @tmpdir, cipher_key: @cipher_key)
    @index = Kasefet::IndexedFlatKV.new(flat_kv: @encrypted_flat_kv)

    @encrypted_flat_kv["foo"] = "1"
    @encrypted_flat_kv["bar"] = "1"
    @encrypted_flat_kv["baz"] = "1"

    @index.rebuild_index
    assert @index.has_key?("foo")
    assert @index.has_key?("bar")
    assert @index.has_key?("baz")
    assert_equal ["foo", "bar", "baz"].sort, @index.each_keys.to_a.sort

    # test that the index file itself is encrypted
    @index.save_index
    unencrypted_file = @index.index.format(@index.index_file)
    refute_equal unencrypted_file, File.binread(@index.index_file)
  end
end
