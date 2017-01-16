module Operators
  module ExtendedMethods
    def added(parser)
      parser.result[self::OPERATOR.name] = self::OPERATOR
    end



    def handle_next(parser)
      return unless parser.peek(self::OPERATOR.name.length) == self::OPERATOR.name.to_s
      parser.result << parser.next(self::OPERATOR.name.length).to_sym # temporary

    end


  end

  module_function

  def extended(other)
    other.extend ExtendedMethods
  end

end