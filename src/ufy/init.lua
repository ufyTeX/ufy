local path = require("path")

local ufy = {}

-- Cache ufy’s config directory location.
local ufy_config_dir

  -- Location of standalone LuaTeX binary in a regular
  -- installation of ufy.
local luatex_program = "luatex"

-- Locate ufy’s config directory.
function ufy.locate_config()
  local datafile = require("datafile")
  local luarocks_opener = require("datafile.openers.luarocks")

  -- Try LuaRocks opener
  datafile.openers = { luarocks_opener }
  ufy_config_dir = datafile.path("config")

  if ufy_config_dir == nil then
    print("Could not locate config. Aborting…")
    os.exit(1)
  end
end

-- Return ufy’s config directory.
function ufy.config_dir()
  if ufy_config_dir == nil then ufy.locate_config() end
  return ufy_config_dir
end

-- Run the ufy program.
--
-- Setup and invoke the LuaTeX interpreter with a Lua file.
function ufy.run(args)
  -- Locate pre-init file
  local pre_init_file = path.join(ufy.config_dir(), "ufy_pre_init.lua")

  -- Extract basename without extension for jobname
  local jobname, _ = path.splitext(path.basename(args[1]))

  local command_args = {
    luatex_program,             -- LuaTeX binary
    "--shell-escape",           -- Allows io.popen in Lua init script: see http://tug.org/pipermail/luatex/2016-October/006249.html
    "--lua=" .. pre_init_file,  -- Pre-init file
    "--jobname=" .. jobname,    -- Set jobname from filname
    "--ini",                    -- IniTeX mode, no format file
    -- minimal wrapper for executing a Lua file
    "'\\catcode`\\{=1'",
    "'\\catcode`\\}=2'",
    "'\\directlua{ufy.init()}'",
    string.format("'\\directlua{dofile(\"%s\")}'", args[1]),
    "'\\end'"
  }

  local command = table.concat(command_args, " ")
  print(string.format("\n%s\n", command))
  local _, _, code = os.execute(command)
  os.exit(code)
end

function ufy.pre_init()
  texconfig.shell_escape = 't'
end

function ufy.init()
  tex.enableprimitives('',tex.extraprimitives())
  ufy.loader.add_lua_searchers()
  tex.outputmode = 1
  pdf.mapfile(nil)
  pdf.mapline('')
end

ufy.locate_config()
ufy.loader = require("ufy.loader")
return ufy
