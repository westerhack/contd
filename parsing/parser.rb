
class Parser
  require_relative '../core/container'
  require_relative '../std/std_commands'

  attr_reader :options

  def initialize(**options)
    @options = options
    @options[:keywords] ||= {'!': Keyword::Get,
                             '@': Keyword::Call,
                             ';': Keyword::Newline,
                             '$': Keyword::This, }
    @options[:commands] ||= Std::PreCommands
    @options[:get_identifier] ||= [proc{ |s, results| results << s }]
  end

  def parse(body)
    results = Container.new
    # body = parse_precommands(body, results)
    parse_body(body.each_char, results)
  end

  def parse_body(iter, results)
    token = ''
    loop do
      case (token.concat iter.next)
      when comment?
        handle_comment(token, results, iter)
      when begin_container?
        handle_container(token, results, iter)
      when end_container?
        handle_token(token.chop!, results, iter)
        break
      else
        # do nothing, token is already concatinated
      end
    end
    handle_token(token, results, iter)
    raise token unless token.empty?
    results
  end

  private

  # comment handling
    def handle_comment(token, results, iter)
      comment = token[-1]
      handle_token(token.chop!, results, iter)
      loop do 
        case (comment.concat iter.next)
        when end_comment? then break
        end
      end
      fail unless (end_comment? === comment[-1])

      return unless comment.start_with? precommand_prefix
      process_precommand(*comment.sub(precommand_prefix, '').
                                  chop!.
                                  split(' ').collect(&:to_sym),
                         results: results)
    end

    def precommand_prefix
      '#!'
    end

    def process_precommand(cmd, *args, results:)
      command = @options[:commands][cmd]
      raise "Unknown precommand `#{cmd.inspect}`" unless command
      command.call(*args, results: results, parser: self)
    end


    def comment?
      %r(.*#$)
    end

    def end_comment?
      /\n$/
    end

  # container
    def handle_container(token, results, iter)
      handle_token(token.chop!, results, iter)
      results << parse_body(iter, results.class.new(knowns: results.knowns.clone))
    end

    def begin_container?
      /[{(\[]/
    end

    def end_container?
      /[})\]]/
    end


  # token
    def handle_token(token, results, _)
      # take the large token and break it apart into smaller tokens. IE '1+x' --> ['1', '+', 'x']
      return if token.empty?
      break_apart_token(token, results).each{ |sym| process_single_sym(sym, results) }
    end

    def break_apart_token(token, results)
      # DANGEROUS. THIS IS WILL NOT WORK FOR MORE ABSTRACT STUFF
      whitespace = " \n\t".chars
      break_ons = "@!+-*/=^$".chars + whitespace
      # this should split at whitespace and defined operators.
      res = [token]
      break_ons.each do |sym_to_break_on| 
        res.collect! do |e|
          e.partition(sym_to_break_on) # WILL FAIL!
          # 'a+b+c'.partition(/+/) --> ['a', '+', 'b+c']
        end.flatten!.delete_if(&:empty?)
      end
      res.reject!(&whitespace.method(:include?))
      res.collect!(&:to_sym)
      token.clear
      res
    end

    def process_single_sym(sym, results)
      if is_sym_a_keyword? sym
        get_keyword(sym, results)
      else
        get_identifier(sym, results)
      end
    end

      def is_sym_a_keyword?(sym)
        @options[:keywords].include?(sym)
      end

      def get_keyword(sym, results)
        results << @options[:keywords][sym].new
      end

      def get_identifier(sym, results)
        @options[:get_identifier].each{ |func| 
          res = func.call(sym, results)
          break res if res
        }
      end
end





parser = Parser.new


body = parser.parse('''#
#! Include Add=+
#! Include Mul=*
#! Include Assign==
#! Include Index=.
#! Numbers
#! Operators
=(car {
  =(wheels 2);
  # =(fuel 4);
  # =(honk {
  #   disp!@{ \'beep beep\'};
  # });
  $
});
.(car!@{} wheels)
''')
puts '----'
puts body
puts '----'


results = Container.new
body.call(args: body, results: results)
require 'pp'
pp results.knowns




# 1 + (2 * (3 / 4 @) @) @
# 1 +! 2 *! 3 /! 4 @ @ @














# class Object
#   def imp
#     case self
#     when :** then 3
#     when :* then 2
#     when :+ then 1
#     else 4
#     end
#   end
# end

# a = [0, :+, 1, :*, 2, :+, 3]
# a = [0, :*, 1, :+, 2, :+, 3]

# def next_priority(arr, sym)
#   res = []
#   until arr.empty?
#     if (sym.imp) < arr.first.imp
#       res << arr.shift
#     else
#       break
#     end
#   end
#   res
# end

# p next_priority(a.clone, :+).join(' ')
# p next_priority(a.clone, :*).join(' ')
# p next_priority(a.clone, :**).join(' ')
# p next_priority(a.clone, :/).join(' ')





































