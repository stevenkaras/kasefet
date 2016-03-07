require "kasefet/wallet"

class Kasefet
  class MultiWallet
    def initialize(wallets)
      @wallets = wallets
    end

    attr_accessor :wallets

    def load(keyname)
      @wallets.each do |name, wallet|
        contents = wallet.load(keyname)
        return contents unless contents.nil?
      end
      return nil
    end

    def store(keyname, content, name = nil)
      name ||= @wallets.keys.first
      @wallets[name].store(keyname, content)
    end
  end
end
