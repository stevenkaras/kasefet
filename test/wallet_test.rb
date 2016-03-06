require File.expand_path("test_helper", __dir__)

require "kasefet/wallet"
require "fileutils"
require "pathname"

class WalletTest < Minitest::Test
  def setup
    @tmpdir = Pathname.new(Dir.mktmpdir)
    @wallet = Kasefet::Wallet.new(directory: @tmpdir)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_storage_roundtrip
    @wallet.store_credentials("foobar", "sekrit")
    creds = @wallet.read_credentials("foobar")
    assert_equal "sekrit", creds
  end

  def test_reads_existing_wallet
    @wallet.store_credentials("foobar", "sekrit")

    @wallet = Kasefet::Wallet.new(directory: @tmpdir)
    creds = @wallet.read_credentials("foobar")
    assert_equal "sekrit", creds
  end

  def test_salts_keynames
    @wallet.store_credentials("foobar", "sekrit")

    unsalted_path = Kasefet::FlatKV.new(root: @tmpdir + "ksft").dir_for_key("foobar")
    refute File.directory?(unsalted_path)
  end

  def test_password_roundtrip
    @wallet = Kasefet::Wallet.new(directory: @tmpdir, passphrase: "foobarbaz")
    @wallet.store_credentials("foobar", "sekrit")
    creds = @wallet.read_credentials("foobar")
    assert_equal "sekrit", creds

    @wallet = Kasefet::Wallet.new(directory: @tmpdir, passphrase: "foobarbaz")
    after_reload = @wallet.read_credentials("foobar")
    assert_equal "sekrit", after_reload
  end

  def test_keyfile_roundtrip
    File.binwrite(@tmpdir + "keyfile", SecureRandom.random_bytes(32))
    @wallet = Kasefet::Wallet.new(directory: @tmpdir, keyfile: @tmpdir + "keyfile")
  end
end
