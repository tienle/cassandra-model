module CassandraModel
  class Base
    extend Forwardable
    include CassandraModel::Callbacks
    include CassandraModel::Persistence

    def_delegators :self.class, :connection, :connection=
    define_callbacks :save, :create, :update, :destroy

    class << self
      attr_accessor :connection

      def establish_connection(*args)
        @connection = Cassandra.new(*args)
      end  
      
      def column_family(name = nil)
        @column_family || (@column_family = name || self.name.split('::').last)
      end

      def key(name)
        class_eval "def #{name}=(value); @key = value.to_s; end"
      end

      def column(name, type = :string)
        columns[name] = type
        class_eval "def #{name}; #{type.capitalize}Type.load(@attributes[:#{name}]); end"

        if [:string, :integer, :float, :datetime].include?(type)
          class_eval "def #{name}=(value); @attributes[:#{name}] = value.to_s; end"
        else
          class_eval "def #{name}=(value); @attributes[:#{name}] = #{type.capitalize}Type.dump(value); end"
        end
      end

      def validate(&block)
        raise ArgumentError.new('provide a block that does validation') unless block_given?
        @validation = block
      end

      def validation
        @validation
      end

      def columns
        @columns ||= {}
      end
    end

    attr_accessor :new_record
    attr_reader :key, :attributes, :errors

    def initialize(attrs={})
      @new_record = true
      @errors     = []
      @attributes = {}
      @attributes = {}
      attributes  = attrs unless attrs.empty?
    end

    def attributes=(attrs)
      attrs.each {|k, v| send("#{k}=", v) }
    end

    def valid?
      self.instance_eval(&self.class.validation) unless self.class.validation.nil?
      @errors.empty?
    end

    def new_record?
      @new_record
    end
  end

end
