require_relative '../../operators_extend'
require_relative '../../operator'

module Operators::Index
  module Stack
    extend Operators

    OPERATOR = Operator.new( '.$', 5 ){ |args, current|
      position = args.pop
      object = args.pop
      current << object.stack.fetch(position){ raise "Stack position not found `#{position}`" }
    }

  end
end
