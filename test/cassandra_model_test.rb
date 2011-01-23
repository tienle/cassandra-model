
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class User < CassandraModel::Base
  column_family :Users

  key :username
  column :full_name
  column :created_at, :datetime

  write_consistency_level Cassandra::Consistency::ALL

  before_save :set_default_time

  validate do
    errors << "full name required" if full_name.nil? || full_name.empty?
  end

private

  def set_default_time
    self.created_at = Time.now
  end
end

class CassandraModelTest < Test::Unit::TestCase
  context "CassandraModel" do
    setup do
      @connection = CassandraModel::Base.establish_connection("CassandraModel")
      @connection.clear_keyspace!

      @user = User.create(:username => "tl", :full_name => "tien le")
    end

    should "be able to connect to Cassandra" do
      assert_kind_of Cassandra, @connection
      assert_equal "CassandraModel", @connection.keyspace
    end

    should "not create a new user when validation fails" do
      user = User.create(:username => "tl")
      assert !user.valid?
      assert user.new_record?

      user = User.new(:username => "tl").save
      assert user.new_record?
      assert_equal "full name required", user.errors.first

      user = User.new(:full_name => "tl").save
      assert_equal "key required", user.errors.first
    end

    should "create a new user when validation passed" do
      assert !@user.new_record?
      assert @user.eql?(User.get("tl"))
      assert_equal @user, User.get("tl")
      assert_equal "tien le", User.get("tl").full_name

      user = User.new(:username => "abc", :full_name => "Foo")
      user.save
      assert_equal ["created_at", "full_name"], @connection.get(:Users, "abc").keys
    end

    should "destroy a record" do
      @user.destroy
      assert User.get("tl").nil?
      assert User.get(nil).nil?

      assert_raise(CassandraModel::RecordNotFound) { User["tl"] }
      assert_raise(CassandraModel::RecordNotFound) { User[nil] }
    end

    should "return true if record exists and otherwise" do
      assert User.exists?("tl")
      assert !User.exists?("foo")
    end

    should "only take defined attributes" do
      user = User.new(:username => "abc", :full_name => "Foo", :hachiko => 'dog')
      user.save
      assert_equal ["created_at", "full_name"], @connection.get(:Users, "abc").keys
    end

    should "truncate the column family" do
      assert !User.all.empty?
      User.truncate!
      assert User.all.empty?
    end
  end
end
