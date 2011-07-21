module CassandraModel
  class StringType
    def self.load(v)
      return '' unless v
      s = v.to_s
      s.clone.force_encoding('UTF-8') if (RUBY_VERSION > '1.9' && s.encoding.name.downcase != 'utf-8')
      s
    end
  end

  class IntegerType
    def self.load(v)
      v && v.to_i
    end
  end

  class FloatType
    def self.load(v)
      v && v.to_f
    end
  end

  class DatetimeType
    def self.dump(v)
      v && v.strftime('%FT%T%z')
    end

    def self.load(v)
      v && ::DateTime.strptime(v, '%FT%T%z')
    end
  end

  class JsonType
    def self.dump(v)
      v && ::JSON.dump(v)
    end

    def self.load(v)
      v && ::JSON.load(v)
    end
  end

  class BooleanType
    def self.dump(v)
      v ? '1' : '0'
    end

    def self.load(v)
      v == '1'
    end
  end
end
