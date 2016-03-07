require File.expand_path("test_helper", __dir__)

require "kasefet/config"
require "kasefet/cli"
require "kasefet/wallet"
require "fileutils"
require 'clipboard'

class CLITest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @config = Kasefet::Config.new(@tmpdir + "kasefet.json")
    @config["wallet"] = @tmpdir + "wallet"
    @config.save
    @cli = Kasefet::CLI.new
    Clipboard.clear
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
    Clipboard.clear
  end

  def test_loads_config_from_option
    config = @cli.load_config(config: @config.file)
    assert_equal config.file, @config.file
    assert_equal config["wallet"], @config["wallet"]
  end

  def test_creates_wallet
    @cli.load_config(config: @config.file)
    wallets = @cli.load_wallet
    assert_equal wallets.wallets.values.first.root.to_s, @config["wallet"]
  end

  def test_stores_and_prints_a_password
    saved_content = @cli.add("foo", "bar", "baz", config: @config.file)
    assert_equal "bar baz", saved_content

    assert_output(/^bar baz$/) do
      loaded_content = @cli.show("foo", config: @config.file)
      assert_equal "bar baz", loaded_content
    end
  end

  def test_copy_paste_keyboard
    saved_content = @cli.add("foo", "bar", "baz", config: @config.file)
    loaded_content = @cli.copy("foo", config: @config.file)
    assert_equal saved_content, loaded_content
    clipboard_content = Clipboard.paste
    assert_equal saved_content, clipboard_content
  end
end
