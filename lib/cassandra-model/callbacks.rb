module CassandraModel
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def define_callbacks(*callbacks)
        callbacks.each do |callback|
          [:before, :after].each do |chain|
            callback_name = "#{chain}_#{callback}"
            instance_eval <<-EVAL, __FILE__, __LINE__ + 1
              def #{callback_name}(*args)
                callbacks[:#{callback_name}] += args
              end
            EVAL
          end
        end
      end

      def callbacks
        @callbacks ||= Hash.new {|h, k| h[k] = [] }
      end
    end

    module InstanceMethods
      def run_callbacks(name, &block)
        _run_callbacks(:before, name)
        result = block.call
        _run_callbacks(:after, name, result)
        result
      end

      private
      def _run_callbacks(chain, name, value = nil)
        callback_name = "#{chain}_#{name}".to_sym
        self.class.callbacks[callback_name].each do |callback|
          next unless callback.is_a? Symbol
          if self.class.instance_method(callback).arity > 0
            self.send(callback, value)
          else
            self.send(callback)
          end
        end
      end
    end
  end
end
