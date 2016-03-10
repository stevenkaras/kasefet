require 'socket'

require 'kasefet/flat_kv'

class Kasefet
  # FlatKV where values are stored encrypted on the disk
  class EncryptedFlatKV < Kasefet::FlatKV
    CipherIVLength = 12
    CipherAuthTagLength = 16

    def initialize(cipher_key:, **options)
      super(**options)
      @cipher = OpenSSL::Cipher.new("aes-256-gcm")
      @cipher_key = cipher_key
    end

    attr_accessor :cipher_key

    def reencrypt_all_values!(new_key)
      old_key = @cipher_key

      Dir[@root + "*" + "*" + "*"].each do |encrypted_file|
        old_encrypted_value = File.binread(encrypted_file)
        value = decrypt_value(old_encrypted_value, old_key)
        new_encrypted_value = encrypt_value(value, new_key)
        File.binwrite(encrypted_file, new_encrypted_value)
      end
      @cipher_key = new_key
    end

    def encrypt_value(value, cipher_key)
      @cipher.encrypt
      @cipher.key = cipher_key
      iv = @cipher.random_iv
      @cipher.iv = iv
      @cipher.auth_data = ""
      encrypted_value = @cipher.update(value) + @cipher.final
      encrypted_value = @cipher.auth_tag + encrypted_value
      encrypted_value = iv + encrypted_value
      return encrypted_value
    end

    def decrypt_value(encrypted_value, cipher_key)
      @cipher.decrypt
      @cipher.key = cipher_key
      @cipher.iv = encrypted_value[0...CipherIVLength]
      encrypted_value = encrypted_value[CipherIVLength..-1]
      @cipher.auth_tag = encrypted_value[0...CipherAuthTagLength]
      encrypted_value = encrypted_value[CipherAuthTagLength..-1]
      value = @cipher.update(encrypted_value) + @cipher.final
      return value
    end

    def read_value_file(file_path)
      encrypted_contents = super(file_path)
      return nil if encrypted_contents.nil?
      return decrypt_value(encrypted_contents, @cipher_key)
    end

    def format_value(key, value)
      value = super(key, value)
      return encrypt_value(value, @cipher_key)
    end
  end
end
