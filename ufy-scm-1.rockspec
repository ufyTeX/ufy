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
  "luaharfbuzz >= 0.0.7",
  "luabidi >= 0.0.4",
  "compat53 >= 0.0.3",
  "datafile >=0.3",
  "lua-path >= 0.3.0"
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
