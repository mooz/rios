#!/usr/bin/env ruby

require "rios-proxy"

class Script
  DEFAULT_SCRIPT = "typescript"

  def initialize(path = DEFAULT_SCRIPT, options = {})
    @proxy = Rios::Proxy.new
    @file = open(path, options[:append] ? "a" : "w")
    setup_listeners()
  end

  def start()
    puts start_message
    @proxy.listen
    puts finish_message
  end

  private

  def setup_listeners
    @proxy.on_output { |s|
      @file.syswrite(s)
      s
    }

    @proxy.on_finish {
      @file.close
    }
  end

  def decorate_message(message)
    <<EOS
============================================================
#{message}
============================================================
EOS
  end

  def start_message()
    decorate_message("Script started, file is #{@file.path}")
  end

  def finish_message()
    decorate_message("Script finished, file is #{@file.path}")
  end
end

script = Script.new()
script.start
