#!/usr/bin/env ruby

require "rios-proxy"

proxy = Rios::Proxy.new

open("/tmp/script", "w") do |file|
  proxy.output do |s|
    file.write(s)
  end

  proxy.listen()
end
