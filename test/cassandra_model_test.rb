
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class CassandraModelTest < Test::Unit::TestCase
  context "CassandraModel" do
    setup do
      @connection = CassandraModel::Base.establish_connection('CassandraModel')
      @connection.clear_keyspace!
    end

    should "be able to connect to Cassandra" do
      assert_kind_of Cassandra, @connection
      @connection.insert(:Users, 'tl', {'firstname' => 'tien'})
      assert_equal({'firstname' => 'tien'}, @connection.get(:Users, 'tl'))
      @connection.remove(:Users, 'tl')
    end
  end
end
