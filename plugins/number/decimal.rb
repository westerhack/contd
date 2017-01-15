require_relative 'int'

module Number
  module Decimal

    module_function

    def process_stream(stream:, result:, **_ )
      stream_copy = stream.clone

      if Int.process_stream(stream: stream, result: result, **_)
        left = result.pop # int pushes it into the input stream
      else
        stream.reset_to stream_copy
        return 
      end
      
      if stream.peek == '.'
        deci = stream.next
      else
        stream.reset_to stream_copy
        return
      end

      if Int.process_stream(stream: stream, result: result, **_)
        right = result.pop # int pushes it into the input stream
      else
        stream.reset_to stream_copy
        return 
      end

      result << "#{left}#{deci}#{right}".to_f
    end

   end
end

