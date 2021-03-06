require_relative 'container'

class Parser
  EOFError = Class.new( SyntaxError )
  module DefaultPlugin
    module_function
    def handle_next( parser:, result: )
      result << parser.next
      true
    end
  end

  attr_reader :plugins

  def initialize(input, plugins: nil)
    @chars = input.chars
    @plugins = plugins || [DefaultPlugin]
  end

  # --- Parsing --- #
  def add(plugin)
    @plugins.unshift plugin
    plugin.added(self) if plugin.respond_to?(:added)
  end

  def run
    result = Container.new
    handle_next(result: result) until empty?
    result
  end

  def handle_next(result:)
    @plugins.each do |plugin|
      res = plugin.handle_next(parser: self, result: result )
      return handle_next(result: result) if res == :retry
      return result if res
    end
  end

  def peek_handle_next(result:)
    clone.handle_next(result: result.clone)
  end

  def fork(input)
    self.class.new(input, plugins: @plugins.clone)
  end

  def clone
    self.class.new(@chars.clone.join, plugins: @plugins.clone)
  end

  # --- Stream --- #
  def next(amnt=1)
    @chars.empty? and fail(EOFError, "Reached end of stream!")
    @chars.shift(amnt).join
  end

  def feed(*vals)
    @chars.unshift *vals
  end

  def empty?
    @chars.empty?
  end

  def peek(amnt=1)
    @chars.first(amnt).join
  end

  def to_a
    @chars.clone
  end

  def next_while(&block)
    res = []
    res << self.next while block.call(self.peek)
    res.join
  end
  
  # --- Representaiton --- #
  def to_s
    @chars.to_s
  end

end

