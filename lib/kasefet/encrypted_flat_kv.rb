require 'socket'

require 'kasefet/flat_kv'

class Kasefet
  # FlatKV where values are stored encrypted on the disk
  class EncryptedFlatKV < Kasefet::FlatKV
    def initialize(cipher_key:, cipher_iv:, cipher: OpenSSL::Cipher.new("aes-256-cbc"), **options)
      super(**options)
      @cipher = cipher
      @cipher_key = cipher_key
      @cipher_iv = cipher_iv
    end

    attr_accessor :cipher, :cipher_key, :cipher_iv

    def [](key)
      encrypted_value = super(key)

      @cipher.decrypt
      @cipher.key = @cipher_key
      @cipher.iv = @cipher_iv
      value = @cipher.update(encrypted_value) + @cipher.final

      return value
    end

    def []=(key, value)
      @cipher.encrypt
      @cipher.key = @cipher_key
      @cipher.iv = @cipher_iv
      encrypted_value = @cipher.update(value) + @cipher.final

      super(key, encrypted_value)
    end
  end
end
