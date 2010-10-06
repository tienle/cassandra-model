module CassandraModel
  class Base
    extend Forwardable

    def_delegators :self.class, :connection, :connection=
    # define_model_callbacks :save, :create, :update, :destroy

    class << self
      def connection
        @connection
      end

      def connection=(obj)
        @connection = obj
      end

      def establish_connection(*args)
        self.connection = Cassandra.new(*args)
      end  

      def column(name, type = :string)

      end

      private

      def inherited(child)
        child.instance_variable_set('@connection', @connection)
        super
      end
    end

    attr_reader :attributes

    def initialize(attributes={})
      @new_record = true
      # @attributes = {}.with_indifferent_access
    end

  end

end
