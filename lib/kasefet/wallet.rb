require "fileutils"
require "pathname"
require "securerandom"
require "kasefet/encrypted_flat_kv"
require "kasefet/master_key"

class Kasefet
  class Wallet
    VERSION = 1
    METADATA_DIR = "metadata"
    CREDENTIALS_DIR = "ksft"
    KSFT_SALT_LENGTH = 16

    def initialize(directory:, passphrase: nil, keyfile: nil)
      @root = Pathname.new(directory)
      FileUtils.mkdir_p(@root)

      @master_key = Kasefet::MasterKey.new(@root + "key")

      @metadata = Kasefet::EncryptedFlatKV.new(root: @root + METADATA_DIR, cipher_key: @master_key.key)

      @wallet_version = @metadata["kasefet.wallet_version"]
      if @wallet_version.nil?
        @wallet_version = @metadata["kasefet.wallet_version"] = VERSION.to_s
        @metadata["kasefet.name_salt"] = SecureRandom.random_bytes(KSFT_SALT_LENGTH)
      end
      @wallet_version = @wallet_version.to_i
      raise "Unknown Kasefet Wallet version: #{@wallet_version}" unless @wallet_version <= VERSION

      @name_salt = @metadata["kasefet.name_salt"]
      @credentials = Kasefet::EncryptedFlatKV.new(root: @root + CREDENTIALS_DIR, cipher_key: @master_key.key)
    end

    attr_accessor :root

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
