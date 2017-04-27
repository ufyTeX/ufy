local path = require("path")

local ufy = {}

-- Cache ufy’s config directory location.
local ufy_config_dir

  -- Location of standalone LuaTeX binary in a regular
  -- installation of ufy.
local luatex_program = path.join(path.user_home(), ".ufy", "luatex")

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
  -- Check if LuaTeX binary exists
  print("Checking if luatex is present…")
  if not path.isfile(luatex_program) then
    print("Cannot find LuaTeX binary at " .. luatex_program)
    print("Run ufy --install-luatex to download and install LuaTeX for your platform.")
    os.exit(1)
  end

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
  texconfig.kpse_init = false
  texconfig.shell_escape = 't'
  local fd= require("ufy.file_discovery")
  fd.add_callbacks()
end

function ufy.init()
  tex.enableprimitives('',tex.extraprimitives())
  ufy.loader.revert_package_searchers()
  tex.outputmode = 1
  pdf.mapfile(nil)
  pdf.mapline('')
end

function ufy.setup()
  local cfg = require("luarocks.cfg")
  local fs  = require("luarocks.fs")
  local dir = path.dirname(luatex_program)
  local _, err = fs.make_dir(dir)
  if err ~= nil then
    print(string.format("ERROR: could not create directory: %s.", dir))
    os.exit(1)
  end

  if cfg.platforms.unix then
    local url
    if cfg.platforms.macosx then
      -- Assume 64-bit Intel binary
      url = "https://github.com/deepakjois/ufy/releases/download/luatex-1.0/luatex-osx-x86_64"
    elseif cfg.platforms.linux then
      if cfg.target_cpu == 'x86_64' then
        url = "http://minimals.contextgarden.net/current/bin/luatex/linux-64/bin/luatex"
      else
        url = "http://minimals.contextgarden.net/current/bin/luatex/linux/bin/luatex"
      end
    else
      print("ERROR: could not locate LuaTeX binaries for your platform.")
      os.exit(1)
    end
    print(string.format("Downloading luatex binary into %s…", dir))
    local ok
    ok, err = fs.download(url,luatex_program, nil)
    if not ok then
      print(string.format("ERROR downloading file: %s", err))
      os.exit(1)
    end
    ok = fs.chmod(luatex_program, "755")
    if not ok then print("WARNING: could not make binary executable") end
  elseif cfg.platforms.windows then
    print("ERROR: Support for installing LuaTeX Windows binaries is not available yet.")
    print(string.format("Please compile or find a copy of luatex and copy it to %s", dir))
    os.exit(1)
  end
end

ufy.locate_config()
ufy.loader = require("ufy.loader")
return ufy
