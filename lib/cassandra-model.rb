require 'cassandra'
require 'forwardable'
require 'date'
# require 'active_support/basic_object'
# require 'active_support/json'
# require 'active_model'

$:.unshift(File.dirname(__FILE__))

module CassandraModel
  class CassandraModelError < StandardError;       end
  class UnknownRecord       < CassandraModelError; end
  class InvalidRecord       < CassandraModelError; end
end

unless Object.respond_to? :tap
  class Object
    def tap(value)
      yield(value)
      value
    end
  end
end

# require 'cassandra-model/marshal'
# require 'cassandra-model/validations'
require 'cassandra-model/types'
require 'cassandra-model/callbacks'
require 'cassandra-model/base'

