require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class CassandraModelCallbacksTest < Test::Unit::TestCase
  context "CassandraModel::Base" do
    setup do
      @klass = Class.new(CassandraModel::Base) do
        key :name
        column :age, :integer
        column :dob, :datetime
        column :note, :json

        validate do
          self.errors << "dob required" if dob.nil?
        end
      end

      @klass.establish_connection 'cassandra-model'
    end

    should "connect to cassandra" do
      assert_kind_of Cassandra, @klass.connection
    end

    should "store all defined columns" do
      assert_equal({:age  => :integer ,
                    :dob  => :datetime,
                    :note => :json}   , @klass.columns)
    end

    should "validate model by provided block" do
      assert_kind_of Proc, @klass.validation

      model = @klass.new()
      assert !model.valid?

      model = @klass.new(:name => "tl")
      assert !model.valid?

      model = @klass.new(:name => "tl", :dob => DateTime.now)
      assert model.valid?
      assert_equal "tl", model.key
      assert_kind_of DateTime, model.dob
    end
  end
end
