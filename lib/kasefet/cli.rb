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
      wallet_dir = @config["wallet"] = File.expand_path(DefaultWalletLocation) unless wallet_dir
      @wallet = Kasefet::Wallet.new(directory: wallet_dir)
    end

    def determine_editor
      [
        ENV["VISUAL"],
        ENV["EDITOR"],
        "vi",
        "nano",
        "ed"
      ].find do |editor|
        next unless editor
        # TODO: do some cursory checks to determine if this editor exists
        true
      end
    end

    desc "edit KEYNAME", "open the contents of KEYNAME in an editor, and save the changes"
    def edit(keyname, *content, **options)
      load_config(options)
      load_wallet

      require 'tmpdir'
      require 'pathname'
      Dir.mktmpdir do |tmpdir|
        tmpdir = Pathname.new(tmpdir)
        content = @wallet.load(keyname)
        File.binwrite(tmpdir + keyname, content)

        # invoke the editor
        editor = determine_editor()
        result = system(*editor.split(" "), (tmpdir + keyname).to_s)

        if result.nil?
          puts "Failed to launch editor: `#{editor}`"
        elsif !result
          puts "`#{editor}` exited with error status: #{$?}. Not saving contents"
        else
          new_content = File.binread(tmpdir + keyname)
          @wallet.store(keyname, new_content)
        end
      end
    end

    desc "add KEYNAME CONTENTS...", "store the given CONTENTS in KEYNAME"
    def add(keyname, *content, **options)
      load_config(options)
      load_wallet

      content = content.join(" ")

      @wallet.store(keyname, content)

      return content
    end

    desc "show KEYNAME", "print the contents of KEYNAME to stdout"
    def show(keyname, **options)
      load_config(options)
      load_wallet

      content = @wallet.load(keyname)

      puts content
      return content
    end
  end
end
