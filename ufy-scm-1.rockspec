package = "ufy"
version = "scm-1"
source = {
   url = "git+https://github.com/ufytex/ufy.git"
}
description = {
   summary = "Work in Progress",
   homepage = "https://github.com/ufytex/ufy",
   license = "MIT"
}
dependencies = {
  "lua >= 5.2",
  "datafile >=0.3",
  "luafilesystem >=1.6.3",
  "lpeg >= 1.0.1",
  "lua-path >= 0.3.0"
}
build = {
   type = "builtin",
   modules = {
     ufy = "src/ufy/init.lua",
     ['ufy.fonts'] = 'src/ufy/fonts.lua',
     ['ufy.loader'] = 'src/ufy/loader.lua',
     ['ufy.fontspec'] = 'src/ufy/fontspec.lua'
   },
   install = {
     bin = {
       ['ufy'] = 'bin/ufy'
     }
   },
   copy_directories = { "config" }
}
