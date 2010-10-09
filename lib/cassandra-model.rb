require 'cassandra'
require 'forwardable'
require 'date'
# require 'active_support/basic_object'
# require 'active_support/json'
# require 'active_model'

$:.unshift(File.dirname(__FILE__))

# require 'cassandra-model/marshal'
# require 'cassandra-model/validations'
require 'cassandra-model/types'
require 'cassandra-model/callbacks'
require 'cassandra-model/base'

module CassandraModel
  class CassandraModelError < StandardError;       end
  class UnknownRecord       < CassandraModelError; end
  class InvalidRecord       < CassandraModelError; end
end
