require 'openssl'
require 'pathname'
require 'socket'
require 'fileutils'

class Kasefet
  # Flat file key value storage
  #
  # Flat-file based key-value storage engine that is designed to be compatible with naive sync programs
  class FlatKV
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
      return nil unless value_file
      return File.binread(value_file)
    end

    def []=(key, value)
      key_dir = dir_for_key(key)
      FileUtils.mkdir_p(key_dir)
      value_file_name = Time.now.strftime("%Y%m%d.%H%M%S%6N.") + @device_name + @extension
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
