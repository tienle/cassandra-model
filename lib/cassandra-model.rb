require 'cassandra'
require 'forwardable'
require 'date'

$:.unshift(File.dirname(__FILE__))

module CassandraModel
  class CassandraModelError < StandardError;       end
  class UnknownRecord       < CassandraModelError; end
  class InvalidRecord       < CassandraModelError; end
  class RecordNotFound      < CassandraModelError; end
end

unless Object.respond_to? :tap
  class Object
    def tap(value)
      yield(value)
      value
    end
  end
end

require 'cassandra-model/types'
require 'cassandra-model/callbacks'
require 'cassandra-model/persistence'
require 'cassandra-model/base'

