require "fileutils"
require "pathname"
require "securerandom"
require "kasefet/flat_kv"

class Kasefet
  class Wallet
    VERSION = 1
    METADATA_DIR = "metadata"
    CREDENTIALS_DIR = "ksft"

    def initialize(directory:)
      @root = Pathname.new(directory)
      @metadata = Kasefet::FlatKV.new(root: @root + METADATA_DIR)

      @wallet_version = @metadata["kasefet.wallet_version"]
      if @wallet_version.nil?
        @wallet_version = @metadata["kasefet.wallet_version"] = VERSION.to_s
        @metadata["kasefet.name_salt"] = SecureRandom.random_bytes(16)
      end
      @wallet_version = @wallet_version.to_i
      raise "Unknown Kasefet Wallet version: #{@wallet_version}" unless @wallet_version <= VERSION

      @name_salt = @metadata["kasefet.name_salt"]
      @credentials = Kasefet::FlatKV.new(root: @root + CREDENTIALS_DIR)
    end

    def salted_keyname(name)
      return "#{@name_salt}/#{name}/#{@name_salt}"
    end

    def read_credentials(name)
      return @credentials[salted_keyname(name)]
    end

    def store_credentials(name, creds)
      @credentials[salted_keyname(name)] = creds
    end
  end
end
