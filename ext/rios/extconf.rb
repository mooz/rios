require "mkmf"

extension_name = "util"

dir_config(extension_name)
if have_library("util")
  create_makefile("rios/" + extension_name)
end
