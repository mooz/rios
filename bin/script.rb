#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "rios/proxy"

module Color
  def red(msg)
    "\033[1;31m#{msg}\033[0m"
  end
end

class Script
  include Color

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
      s.gsub!(/@/) { |match| red(match[0]) }
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
