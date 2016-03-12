require 'fileutils'

require 'kasefet/flat_kv'
require 'kasefet/config'

class Kasefet
  class IndexedFlatKV
    def initialize(flat_kv:, index_dir: "index", index_ext: "")
      @flat_kv = flat_kv
      @root = flat_kv.root
      @index_dir = @root + "#{index_dir}"
      @index_file = @index_dir + "index#{index_ext}"
      @index = Kasefet::Config.new(@index_file)
    end

    attr_accessor :index, :index_file

    def [](key)
      return @flat_kv[key]
    end

    def []=(key, value)
      mark_key(key, @flat_kv.key_to_digest(key))
      return @flat_kv[key] = value
    end

    def load_index
      index_contents = @flat_kv.read_file(@index_file)
      @index.parse(index_contents)
    end

    def conflicted?
      Dir[@index_dir + "*"].size != 1
    end

    def rebuild_index
      Dir.foreach(@root) do |prefix|
        next unless prefix =~ /\h\h/
        Dir.foreach(@root + prefix) do |key_dir|
          next unless key_dir =~ /\h{62}/ # SHA256 digest is 64 bytes, first two are the prefix
          Dir.foreach(@root + prefix + key_dir) do |value_file|
            next if [".", ".."].include?(value_file)
            value_path = @root + prefix + key_dir + value_file
            contents = @flat_kv.read_file(value_path)
            key_name, value = @flat_kv.read_value(contents)
            mark_key(key_name, prefix + key_dir)
          end
        end
      end
    end

    def mark_key(key, digest)
      @index["dig:" + digest] = key
      @index["key:" + key] = digest
    end

    def save_index
      index_contents = @index.format
      FileUtils.mkdir_p(@index_dir)
      @flat_kv.write_file(@index.file, index_contents)
    end

    def has_key?(key)
      return !! @index["key:" + key]
    end

    def each_keys
      return enum_for(__method__) unless block_given?

      @index.each_keys do |key|
        next unless key.start_with?("key:")
        yield key[4..-1]
      end
    end
  end
end
