module CassandraModel
  module Persistence
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def save
        return self unless valid?
        run_callbacks :save do
          callback = new_record? ? :create : :update
          run_callbacks callback do
            write(attributes)
          end
        end
      end

      def destroy
        run_callbacks :destroy do
          self.class.remove(key)
        end
      end

      def reload
        self.class.get(key)
      end

      def update_attributes(attrs)
        self.attributes = attrs
        save
      end

      def remove_attributes(attrs)
        attrs.each {|attr| self.class.remove_column(key, attr) }
      end

    private

      def write(attrs)
        self.class.write(key, attrs)
        @new_record = false
        self
      end
    end

    module ClassMethods
      attr_writer :write_consistency_level, :read_consistency_level

      def write_consistency_level(level)
        @write_consistency_level = level
      end

      def read_consistency_level(level)
        @read_consistency_level = level
      end

      def get(key, options = {})
        attrs = connection.get(column_family, key, options)
        return nil if attrs.empty?
        new(attrs, false).tap do |object|
          object.key = key
          object.new_record = false
        end
      rescue
        nil
      end

      alias :find :get

      def [](key)
        record = get(key)
        raise RecordNotFound, "cannot find out key=`#{key}` in `#{column_family}`" unless record
        record
      end

      def exists?(key)
        return false if key.nil? || key == ''
        #connection.exists?(column_family, key)
        !connection.get(column_family, key).empty?
      rescue
        false
      end

      def all(keyrange = ''..'', options = {})
        results = connection.get_range(column_family, :start => keyrange.first,
                                       :finish => keyrange.last, :count => (options[:limit] || 100))
        keys = results.map(&:key)
        keys.map {|key| get(key) }
      end

      def first(keyrange = ''..'', options = {})
        all(keyrange, options.merge(:limit => 1)).first
      end

      def create(attributes)
        new(attributes).tap do |object|
          object.save
        end
      end

      def write(key, attributes)
        connection.insert(column_family, key, attributes,
                          :consistency => @write_consistency_level || Cassandra::Consistency::QUORUM)
        key
      end

      def remove(key)
        connection.remove(column_family, key,
                          :consistency => @write_consistency_level || Cassandra::Consistency::QUORUM)
      end

      def remove_column(key, column)
        connection.remove(column_family, key, column,
                          :consistency => @write_consistency_level || Cassandra::Consistency::QUORUM)
      end

      def truncate!
        connection.truncate!(column_family.to_s)
      end
    end
  end
end
