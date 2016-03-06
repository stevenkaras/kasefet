require "openssl"

class Kasefet
  class MasterKey
    PBKDF2SaltLength = 32
    CipherKeyLength = 32
    CipherIVLength = 12
    CipherAuthTagLength = 16

    def passphrase_to_key(passphrase, salt)
      return OpenSSL::PKCS5.pbkdf2_hmac_sha1(passphrase, salt, 20000, CipherKeyLength)
    end

    def store_key_with_passphrase(passphrase)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      salt = SecureRandom.random_bytes(PBKDF2SaltLength)
      master_key = passphrase_to_key(passphrase, salt)
      cipher.encrypt
      cipher.iv = iv = cipher.random_iv
      cipher.key = master_key
      cipher.auth_data = ""
      encrypted_key = cipher.update(@key) + cipher.final
      encrypted_key = cipher.auth_tag + encrypted_key
      encrypted_key = iv + encrypted_key
      encrypted_key = salt + encrypted_key
      File.binwrite(@file, encrypted_key)
    end

    def store_key_with_keyfile(keyfile)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      master_key = File.binread(keyfile)
      cipher.encrypt
      cipher.iv = iv = cipher.random_iv
      cipher.key = master_key
      cipher.auth_data = ""
      encrypted_key = cipher.update(@key) + cipher.final
      encrypted_key = cipher.auth_tag + encrypted_key
      encrypted_key = iv + encrypted_key
      File.binwrite(@file, encrypted_key)
    end

    def load_key_with_keyfile(keyfile)
      master_key = File.binread(keyfile)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.decrypt
      cipher.iv = @key[0...CipherIVLength]
      @key = @key[CipherIVLength..-1]
      cipher.auth_tag = @key[0...CipherAuthTagLength]
      @key = @key[CipherAuthTagLength..-1]
      cipher.key = master_key
      @key = cipher.update(@key) + cipher.final
    end

    def load_key_with_passphrase(passphrase)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.decrypt
      salt = @key[0...PBKDF2SaltLength]
      @key = @key[PBKDF2SaltLength..-1]
      cipher.iv = @key[0...CipherIVLength]
      @key = @key[CipherIVLength..-1]
      cipher.auth_tag = @key[0...CipherAuthTagLength]
      @key = @key[CipherAuthTagLength..-1]
      cipher.key = passphrase_to_key(passphrase, salt)
      @key = cipher.update(@key) + cipher.final
    end

    def initialize(file, passphrase: nil, keyfile: nil)
      @file = file

      # read in the key
      if File.exist?(@file)
        @key = File.binread(@file)
        if passphrase
          load_key_with_passphrase(passphrase)
        elsif keyfile
          load_key_with_keyfile(keyfile)
        end
      else
        # this is a new wallet, generate a random key
        cipher = OpenSSL::Cipher.new("aes-256-gcm")
        @key = cipher.random_key
        if passphrase
          store_key_with_passphrase(passphrase)
        elsif keyfile
          store_key_with_keyfile(keyfile)
        else
          File.binwrite(@file, @key)
        end
      end
    end

    attr_accessor :key
  end
end
