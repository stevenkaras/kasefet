class Kasefet
  class Config
    def initialize(file)
      @file = file
      @settings = {}
      return unless File.exists?(file)
      load
    end

    attr_accessor :file

    def [](key)
      return key.split(".").reduce(@settings) { |hash, segment| hash ? hash[segment] : nil }
    end

    def []=(key, value)
      last_segment = key.split(".")[0..-2].reduce(@settings) { |hash, segment| hash[segment] ||= {} }
      last_segment[key.split(".")[-1]] = value
    end

    def load
      case File.extname(@file)
      when ".yaml", ".yml"
        require 'yaml'
        @settings = YAML.load(File.read(file))
      when ".json"
        require 'json'
        @settings = JSON.parse(File.read(file))
      else
        # try the key=value format
        content = File.read(file)
        content.split("\n").each do |line|
          key, value = line.split("=")
          value = value.to_i if value =~ /\d+/
          if self[key]
            self[key] = [self[key]] unless self[key].is_a? Array
            self[key] << value
          else
            self[key] = value
          end
        end
      end
    end

    def save
      case File.extname(@file)
      when ".json"
        require 'json'
        File.write(@file, @settings.to_json)
      when ".yaml", ".yml"
        require 'yaml'
        File.write(@file, @settings.to_yaml)
      else
        to_write = flatten_hash(@settings).map do |key, value|
          if value.is_a? Array
            value.map do |array_value|
              "#{key}=#{array_value}"
            end.join("\n")
          else
            "#{key}=#{value}"
          end
        end.join("\n")
        File.write(@file, to_write)
      end
    end

    def flatten_hash(hash)
      hash.reduce({}) do |result, pair|
        key, value = pair
        if value.is_a? Hash
          flatten_hash(value).each do |suffix, subvalue|
            result["#{key}.#{suffix}"] = subvalue
          end
        else
          result[key] = value
        end
        result
      end
    end
  end
end