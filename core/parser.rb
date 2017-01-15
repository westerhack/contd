class Parser
  require_relative 'container'

  # --- Attributes and Class methods --- #
    attr_reader :plugins

    def self.plugin_method(sym)
      define_method(sym) do |*a, &b|
        @plugins.each do |plugin|
          next unless plugin.respond_to?(sym)
          res = plugin.method(sym).call(*a, &b) and return res
        end
        nil
      end
    end


    plugin_method :next_token
    plugin_method :handle_token


  def initialize(*plugins)
    @plugins = plugins
  end

  def parse(input)
    result = Container.new
    iter = input.each_char
    loop do 
      token = next_token(iter) || iter.next # default
      handle_token(token, result, iter) || result << token # default
    end
    result
  end

end












