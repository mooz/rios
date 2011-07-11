#!/usr/bin/env ruby

require "rios-proxy"

proxy = Rios::Proxy.new

file_path = "/tmp/script"

file = open(file_path, "w")

puts <<EOS
============================================================
Begin recording script into #{file_path}
============================================================
EOS

proxy.on_output do |s|
  s = s.gsub(/a/, "!")
  file.write(s)
  s
end

proxy.on_finish do ||
  file.close

  puts <<EOS
============================================================
Recorded script into #{file_path}
============================================================
EOS
end

proxy.listen
