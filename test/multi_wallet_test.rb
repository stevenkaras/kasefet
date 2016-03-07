require File.expand_path("test_helper", __dir__)

require "kasefet/multi_wallet"
require "fileutils"
require "pathname"

class MultiWalletTest < Minitest::Test
  def setup
    @tmpdir1 = Pathname.new(Dir.mktmpdir)
    @tmpdir2 = Pathname.new(Dir.mktmpdir)
    @tmpdir3 = Pathname.new(Dir.mktmpdir)
    @wallet1 = Kasefet::Wallet.new(directory: @tmpdir1)
    @wallet2 = Kasefet::Wallet.new(directory: @tmpdir2)
    @wallet3 = Kasefet::Wallet.new(directory: @tmpdir3)
    @wallets = Kasefet::MultiWallet.new({one: @wallet1, two: @wallet2, three: @wallet3})
  end

  def teardown
    [@tmpdir1, @tmpdir2, @tmpdir3].each do |tmpdir|
      FileUtils.remove_entry(tmpdir)
    end
  end

  def test_storage_roundtrip
    @wallets.store("foobar", "sekrit")
    creds = @wallets.load("foobar")
    assert_equal "sekrit", creds
  end

  def test_stores_values_in_specific_wallet
    @wallets.store("foobar", "sekrit", :two)
    creds = @wallet2.load("foobar")
    assert_equal "sekrit", creds
  end
end
