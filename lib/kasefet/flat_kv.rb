require 'openssl'
require 'pathname'
require 'socket'
require 'fileutils'

class Kasefet
  # Flat file key value storage
  #
  # Flat-file based key-value storage engine that is designed to be compatible with naive sync programs
  class FlatKV
    MagicNumber = "KSFT"

    # @option [String] :root The root directory of the FlatKV store
    # @option [String] :device_name The device name to use to identify the writer
    # @option [String] :extension The default extension to use for the value files
    def initialize(root:, device_name: Socket.gethostname, extension: "")
      @root = Pathname.new(root)
      @extension = extension
      @device_name = device_name
    end

    attr_accessor :root, :extension, :device_name

    def extension=(value)
      value = ".#{value}" unless value.start_with?(".")
      @extension = value
    end

    def [](key)
      value_file = file_for_key(key)
      contents = read_value_file(value_file)
      _, value = read_value(contents)
      return value
    end

    def read_value_file(file_path)
      return nil unless file_path
      return File.binread(file_path)
    end

    def read_value(contents)
      return nil, nil unless contents

      raise "FlatKV value file must be at least 8 bytes long" unless contents.bytesize >= 8
      magic_number, key_size, contents = contents.unpack("A4NA*")
      raise "FlatKV value file must be a KSFT file" unless magic_number == MagicNumber
      raise "FlatKV value file has been corrupted. Key length in header is longer than file" unless contents.bytesize >= key_size
      key_name, contents = contents.unpack("A#{key_size}A*")

      return key_name, contents
    end

    def format_value(key, value)
      [MagicNumber, key.bytesize, key, value].pack("A4NA*A*")
    end

    def []=(key, value)
      key_dir = dir_for_key(key)
      FileUtils.mkdir_p(key_dir)
      value_file_name = Time.now.strftime("%Y%m%d.%H%M%S%6N.") + @device_name + @extension

      value = format_value(key, value)

      File.binwrite(key_dir + value_file_name, value)
    end

    def file_for_key(key)
      key_dir = dir_for_key(key)
      files = Dir.glob(key_dir + "*#{@extension}")
      return nil if files.empty?
      return files.last
    end

    def dir_for_key(key)
      digest = OpenSSL::Digest::SHA256.hexdigest(key)
      return @root + digest[0..1] + digest[2..-1]
    end
  end
end
