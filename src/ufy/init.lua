local utf8 = require("compat53.utf8")
local path = require("path")

local ufy = {}
ufy.fonts = require("ufy.fonts")

local ufy_config_dir

-- Locate ufy’s config directory
function ufy.locate_config()
  local datafile = require("datafile")
  local luarocks_opener = require("datafile.openers.luarocks")
  local unix_config_opener = require("datafile.openers.unix")
  -- Try LuaRocks opener
  datafile.openers = { luarocks_opener }
  ufy_config_dir = datafile.path("config")

  if ufy_config_dir == nil then
    print("WARNING could not locate ufy’s config folder in LuaRocks tree.")
    print("Looking in $HOME/.ufy")
    -- Try Unix opener
    datafile.openers = { unix_config_opener}
    ufy_config_dir = datafile.path("ufy/config", "r", "config")
    if ufy_config_dir == nil then
      print("Could not locate config. Aborting…")
      os.exit(1)
    end
  end
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- Run the ufy program.
--
-- Setup and invokes the LuaTeX interpreter with a Lua file.
function ufy.run(args)
  -- Location of standalone LuaTeX binary in a regular
  -- installation of ufy.
  local luatex_program = os.getenv('HOME') .. "/.ufy/luatex"

  -- Check if LuaTeX binary exists
  print("Checking if luatex is present…")
  if not file_exists(luatex_program) then
    print("Cannot find LuaTeX binary at " .. luatex_program)
    print("Run ufy --install-luatex to download and install LuaTeX for your platform.")
    os.exit(1)
  end

  ufy.locate_config()

  -- Locate pre-init file
  local pre_init_file = ufy_config_dir .. "/ufy_pre_init.lua"

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

-- Copied from: http://tex.stackexchange.com/questions/218855/using-lualatex-and-sqlite3/219228#219228
local function make_loader(ppath, pos, loadfunc)
  local default_loader = package.searchers[pos]
  local loader = function(name)
    local file, _ = package.searchpath(name,ppath)
    if not file then
      local msg = "\n\t[lualoader] Search failed"
      local ret = default_loader(name)
      if type(ret) == "string" then
        return msg ..ret
      elseif type(ret) == "nil" then
        return msg
      else
        return ret
      end
    end
    local loader,err = loadfunc(file, name)
    if not loader then
      return "\n\t[lualoader] Loading error:\n\t"..err
    end
    return loader
  end
  package.searchers[pos] = loader
end

local function binary_loader(file, name)
  local symbol = name:gsub("%.","_")
  return package.loadlib(file, "luaopen_"..symbol)
end

-- Revert the package searchers to use package.path and package.cpath.
--
-- Package searching logic is overridden by default in LuaTeX to use kpse.
-- Calling this function reverts the searchers to use package.path and
-- package.cpath first, failing which it will try the kpse based searcher.
--
-- Package Loading References:
-- 1. http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
-- 2. LuaTeX Manual, Section 3.2, Lua behavior
function ufy.switch_package_searchers()
  make_loader(package.path,2,loadfile)
  make_loader(package.cpath,3, binary_loader)
end

function ufy.init()
  tex.enableprimitives('',tex.extraprimitives())
  ufy.switch_package_searchers()
  tex.outputmode = 1
  pdf.setpkresolution(600)
  pdf.setminorversion(5)
  pdf.mapfile(nil)
  pdf.mapline('')
  local fontid = ufy.fonts.load_font(string.format("%s/fonts/%s", ufy_config_dir, "Merriweather-Light.ttf"), 10)
  font.current(fontid)
end


local function reader( asked_name )
  -- print("reader: "..asked_name)
  local tab = { }
  tab.file = io.open(asked_name,"rb")
  if tab.file == nil then error("Could not read "..asked_name) end
  tab.reader = function (t)
                  local f = t.file
                  return f:read('*l')
               end
  tab.close = function (t)
                  t.file:close()
              end
  return tab
end

local function read_file( name )
  -- print("read_file: "..name)
  local f, err = io.open(name,"rb")
  if f == nil then error(err) end
  local buf = f:read("*all")
  f:close()
  return true,buf,buf:len()
end

local function return_asked_name( asked_name )
  -- print("in return_asked_name: "..asked_name)
  return asked_name
end

local function return_asked_name_id(_, asked_name)
  -- print("in return_asked_name_id: "..asked_name)
  return asked_name
end

local function error_xxx_file(name)
  print("error_xxx_file: "..name)
  print("ERROR: should not get here.")
  return nil
end

local function find_format_file(name)
  -- print("in find_format_file")
  return string.format("%s/%s", ufy_config_dir, name)
end

local function find_map_file(name)
  -- print("find_map_file: "..name)
  return string.format("%s/fonts/%s", ufy_config_dir, name)
end

local function find_font_file(name)
  -- print("find_font_file: "..name)
  if file_exists(name) then
    return name
  else
    return string.format("%s/fonts/%s", ufy_config_dir, name)
  end
end

-- Add file discovery callbacks that LuaTeX requires when kpse
-- is not initialized
--
-- ufy starts up by setting texconfig.kpse_init to false, which means
-- we need to implement the file discovery callbacks ourselves. However,
-- ufy does not need to implement all the file discovery callbacks. Some
-- callbacks have been stubbed out, and some others throw an error because
-- there is no reason for them to be called during normal operation.
function ufy.add_file_discovery_callbacks()
  ufy.locate_config()
  callback.register('open_read_file',reader)
  callback.register('find_output_file',  return_asked_name)
  callback.register('find_write_file', return_asked_name_id)
  callback.register('find_read_file', return_asked_name_id)

  callback.register('find_format_file', find_format_file)

  callback.register('find_map_file', find_map_file)
  callback.register('read_map_file', read_file)
  callback.register('find_font_file', find_font_file)
  callback.register('read_font_file', read_file)

  callback.register('find_opentype_file',find_font_file)
  callback.register('find_type1_file',   find_font_file)
  callback.register('find_truetype_file',find_font_file)

  callback.register('read_opentype_file',read_file)
  callback.register('read_type1_file',   read_file)
  callback.register('read_truetype_file',read_file)

  for _,t in ipairs({'find_vf_file','find_enc_file','find_sfd_file','find_pk_file','find_data_file','find_image_file'}) do
    callback.register(t,error_xxx_file)
  end

  for _,t in ipairs({'read_vf_file','read_sdf_file','read_pk_file','read_data_file'}) do
    callback.register(t, error_xxx_file )
  end
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


return ufy
