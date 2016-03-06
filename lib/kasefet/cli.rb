require "thunder"

require "kasefet/config"
require "kasefet/wallet"

class Kasefet
  class CLI
    GlobalConfigLocations = [
      "~/.kasefet",
      "~/.config/kasefet",
    ]

    DefaultWalletLocation = "~/.wallet"

    include Thunder

    def load_config(options)
      config_file = options[:config]
      config_file ||= GlobalConfigLocations.find { |file| File.exist?(File.expand_path(file)) }
      config_file ||= File.expand_path(GlobalConfigLocations.first)
      @config = Kasefet::Config.new(config_file)
    end

    def load_wallet
      wallet_dir = @config["wallet"]
      wallet_dir = @config["wallet"] = DefaultWalletLocation unless wallet_dir
      @wallet = Kasefet::Wallet.new(directory: wallet_dir)
    end

    desc "add KEYNAME CONTENT..."
    def add(keyname, *content, **options)
      load_config(options)
      load_wallet

      content = content.join(" ")

      @wallet.store(keyname, content)

      return content
    end

    desc "show KEYNAME"
    def show(keyname, **options)
      load_config(options)
      load_wallet

      content = @wallet.load(keyname)

      puts content
      return content
    end
  end
end
