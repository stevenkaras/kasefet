class Kasefet
  class Config
    def initialize(file)
      @file = file
      @settings = {}
    end

    attr_accessor :file

    def [](key)
      return key.split(".").reduce(@settings) { |hash, segment| hash ? hash[segment] : nil }
    end

    def []=(key, value)
      last_segment = key.split(".")[0..-2].reduce(@settings) { |hash, segment| hash[segment] ||= {} }
      last_segment[key.split(".")[-1]] = value
    end

    def each_keys()
      return @settings.keys.each unless block_given?

      @settings.keys.each do |key|
        yield key
      end
    end

    def load
      return unless File.exists?(@file)
      parse(File.read(@file))
    end

    def parse(contents, file_path = @file)
      case File.extname(file_path)
      when ".yaml", ".yml"
        require 'yaml'
        @settings = YAML.load(contents)
      when ".json"
        require 'json'
        @settings = JSON.parse(contents)
      else
        # try the key=value format
        content = contents
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
      File.write(@file, format())
    end

    def format(file_path = @file)
      case File.extname(file_path)
      when ".json"
        require 'json'
        return @settings.to_json
      when ".yaml", ".yml"
        require 'yaml'
        return @settings.to_yaml
      else
        return flatten_hash(@settings).map do |key, value|
          if value.is_a? Array
            value.map do |array_value|
              "#{key}=#{array_value}"
            end.join("\n")
          else
            "#{key}=#{value}"
          end
        end.join("\n")
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