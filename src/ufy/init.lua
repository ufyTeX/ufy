local utf8 = require("compat53.utf8")
local path = require("path")

local ufy = {}
ufy.fonts = require("ufy.fonts")
ufy.loader = require("ufy.loader")


local ufy_config_dir

-- Locate ufy’s config directory
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

-- Return ufy’s config directory
function ufy.config_dir()
  if ufy_config_dir == nil then ufy.locate_config() end
  return ufy_config_dir
end

-- Run the ufy program.
--
-- Setup and invoke the LuaTeX interpreter with a Lua file.
function ufy.run(args)
  -- Location of standalone LuaTeX binary in a regular
  -- installation of ufy.
  local luatex_program = path.join(path.user_home(), ".ufy", "luatex")

  -- Check if LuaTeX binary exists
  print("Checking if luatex is present…")
  if not path.isfile(luatex_program) then
    print("Cannot find LuaTeX binary at " .. luatex_program)
    print("Run ufy --install-luatex to download and install LuaTeX for your platform.")
    os.exit(1)
  end

  -- Locate pre-init file
  local pre_init_file = ufy.config_dir() .. "/ufy_pre_init.lua"

  -- Extract basename without extension for jobname
  local jobname, _ = path.splitext(path.basename(args[1]))

  local command_args = {
    luatex_program,             -- LuaTeX binary
    "--shell-escape",           -- Allows io.popen in Lua init script: see http://tug.org/pipermail/luatex/2016-October/006249.html
    "--lua=" .. pre_init_file,  -- Pre-init file
    "--jobname=" .. jobname,    -- Set jobname from filname
    "--ini",                    -- IniTeX mode, no format file
    -- minimal setup before running
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

-- build paragraph node
-- adapted from: http://tex.stackexchange.com/questions/114568/can-i-create-a-node-list-from-some-text-entirely-within-lua
function ufy.text_to_paragraph(text)
  local current_font = font.current()
  local font_params = font.getfont(current_font).parameters

  local para_head = node.new("local_par")
  para_head.dir = "TLT"

  local last = para_head

  local indent = node.new("hlist",3)
  indent.width = tex.parindent
  last.next = indent
  last = indent

  for _,v in utf8.codes(text) do
    local n
    if v < 32 then
      goto skipchar
    elseif v == 32 then -- FIXME use Unicode properties to identify whitespace
      n = node.new("glue",13)
      node.setglue(n, font_params.space, font_params.space_shrink, font_params.space_stretch)
    else
      n = node.new("glyph", 1)
      n.font = current_font
      n.char = v
      n.lang = tex.language
      n.uchyph = 1
      n.left = tex.lefthyphenmin
      n.right = tex.righthyphenmin
    end
    last.next = n
    last = n
    ::skipchar::
  end

  -- now add the final parts: a penalty and the parfillskip glue
  local penalty = node.new("penalty", 0)
  penalty.penalty = 10000

  local parfillskip = node.new("glue", 14)
  parfillskip.stretch = 2^16
  parfillskip.stretch_order = 2

  last.next = penalty
  penalty.next = parfillskip

  node.slide(para_head)
  return para_head
end

ufy.locate_config()

return ufy
