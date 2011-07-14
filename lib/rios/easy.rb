require "rios/proxy"

module Rios
  module Easy
    @@proxy = Rios::Proxy.new

    # Inspired from Sinatra
    def self.delegate(*methods)
      methods.each do |method_name|
        eval <<-RUBY, binding, '(__DELEGATE__)', 1
          def #{method_name}(*args, &block)
            @@proxy.send(#{method_name.inspect}, *args, &block)
          end
          private #{method_name.inspect}
        RUBY
      end
    end

    delegate :on_input, :on_output, :on_finish, :input, :output, :listen
  end
end

class Object
  include Rios::Easy
end
