require_relative '../operators_extend'
require_relative '../operator'

module Operators::Equal
  extend Operators

  OPERATOR = Operator.new '==', 20
  
end