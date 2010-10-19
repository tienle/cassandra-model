
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

class Post < CassandraModel::Base
  column_family :Posts

  key :slug
  column :title
  column :content
  column :author
  column :tags

  after_create :create_tags

end

class Comment < CassandraModel::Base
  column_family :Comments
  key :slug
end

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

    should "not create a new user when validation fails" do
      user = User.create(:username => 'tl')
      assert !user.valid?
      assert user.new_record?

      user = User.new(:username => 'tl').save
      assert user.new_record?
      assert_equal "full name required", user.errors.first

      user = User.new(:full_name => 'tl').save
      assert_equal "key required", user.errors.first
    end

    should "create a new user when validation passed" do
      user = User.create(:username => 'tl', :full_name => 'tien le')
      assert !user.new_record?
      assert_equal user, User.get('tl')
      assert user.eql?(User.get('tl'))
      assert_equal 'tien le', User.get('tl').full_name

      user = User.new(:username => 'abc', :full_name => 'Foo')
      user.save
      assert_equal ['created_at', 'full_name'], @connection.get(:Users, 'abc').keys
    end

    should "destroy a record" do
      user = User.create(:username => 'foo', :full_name => 'foo')
      user.destroy
      assert @connection.get(:Users, 'foo').empty?
      assert User.get('foo').nil?
      assert_raise(CassandraModel::RecordNotFound) { User['foo'] }
    end
  end
end
