local utf8 = require("compat53.utf8")
local ufy = {}

-- Copied from: http://tex.stackexchange.com/questions/218855/using-lualatex-and-sqlite3/219228#219228
local make_loader = function(path, pos, loadfunc)
  local default_loader = package.searchers[pos]
  local loader = function(name)
    local file, _ = package.searchpath(name,path)
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

local binary_loader = function(file, name)
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
  pdf.setpkresolution(600)
  pdf.setminorversion(5)
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

  for p,v in utf8.codes(text) do
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
