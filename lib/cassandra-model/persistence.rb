module CassandraModel
  module Persistence
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def save
        run_callbacks :save do
          callback = new_record? ? :create : :update
          run_callbacks callback do
            write
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

    private

      def write
        self.class.write(key, attributes)
        @new_record = false
      end
    end

    module ClassMethods
      attr_accessor :write_consistency_level, :read_consistency_level

      def get(key, options = {})
        new(connection.get(key, options)).tap do |object|
          object.key = key
          object.new_record = false
        end
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
        connection.insert(column_family, key, attributes, :consistency => write_consistency_level)
        key
      end

      def remove(key)
        connection.remove(column_family, key, :consistency => write_consistency_level)  
      end
    end
  end
end
