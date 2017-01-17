module Operators
  module ExtendedMethods
    # def added(parser)
    #   parser.result[self::OPERATOR.name] = self::OPERATOR
    # end


    def priority(token)
      return token.priority if token.respond_to?(:priority)
      case token.to_s
      when ';' then 25
      when '=' then 20
      when '+', '+' then 12
      when '*', '/', '%' then 11
      when '^' then 10
      when '.', '.$', '.?' then 6
      when '@' then 5
      else 0
      end
    end

    def next_token(parser, token, result)
      until parser.empty?
        peeked = parser.peek_handle_next(result: result.clone)
        if peeked.stack[-1].is_a?(Keyword::Call) || peeked.stack[-1].is_a?(Keyword::Get)
          peeked = peeked.stack[-2] # because we have containers
        else
          peeked = peeked.stack[-1]
        end
        if priority(token) > priority(peeked)
          parser.handle_next(result: result)
        else
          break
        end
      end
    end

    def handle_next(parser:, result:)
      return unless parser.peek(self::OPERATOR.name.length) == self::OPERATOR.name.to_s

      parser.next(self::OPERATOR.name.length) #pop this token
      to_add = Container.new # HACKY
      if result.stack[-1].is_a?(Keyword::Call)
        result.pop(3).each(&to_add.method(:push))
      elsif result.stack[-1].is_a?(Keyword::Get)
        result.pop(2).each(&to_add.method(:push))
      else
        to_add << result.pop
      end
      next_token(parser, self::OPERATOR, to_add)
      result << to_add
      result << self::OPERATOR
      result << Keyword::Call.new

    rescue parser.class::EOFError => e
      raise parser.class::EOFError,
            "Reached end of stream whilst looking for rhs of function (`#{self::OPERATOR}`)"
    end


  end

  module_function

  def extended(other)
    other.extend ExtendedMethods
  end

end