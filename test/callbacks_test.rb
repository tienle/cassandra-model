require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class CassandraModelCallbacksTest < Test::Unit::TestCase
  context "CassandraModel::Callbacks" do
    setup do
      @base  = Class.new(Object) do
        include CassandraModel::Callbacks
        define_callbacks :foo
      end

      @klass = Class.new(@base) do
        def bar; @n = [:bar]; end

        def foo
          run_callbacks(:foo) { @n << :foo }
        end

        def baz(v)
          @n << :baz if v == [:bar, :foo]
        end

        def quux; @n << :quux; end
      end
    end

    should "provide before and after callbacks for foo function" do
      assert @klass.respond_to?(:define_callbacks)
      assert @klass.respond_to?(:callbacks)
      assert @klass.respond_to?(:before_foo)
      assert @klass.respond_to?(:after_foo)
      assert_equal Hash.new, @klass.callbacks
    end

    should "invoke callback functions when foo executed" do
      @klass.send(:before_foo, :bar)
      @klass.send(:after_foo, :baz, :quux)
      assert_equal 2, @klass.callbacks.length
      assert_equal [:bar], @klass.callbacks[:before_foo]
      assert_equal [:baz, :quux], @klass.callbacks[:after_foo]
      assert_equal [:bar, :foo, :baz, :quux], @klass.new.foo
    end
  end
end
