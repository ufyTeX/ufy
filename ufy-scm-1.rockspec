package = "ufy"
version = "scm-1"
source = {
   url = "git+https://github.com/deepakjois/ufy.git"
}
description = {
   summary = "Work in Progress",
   homepage = "https://github.com/deepakjois/ufy",
   license = "MIT"
}
dependencies = {
  "lua >= 5.2",
  "luaharfbuzz >= 0.0.4",
  "luabidi >= 0.0.2",
  "compat53 >= 0.0.3"
}
build = {
   type = "builtin",
   modules = {
     ufy = "src/ufy/init.lua"
   },
   install = {
     bin = {
       ['ufy'] = 'bin/ufy'
     }
   },
   copy_directories = { "config" }
}
