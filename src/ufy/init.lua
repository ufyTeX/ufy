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
    local loader,err = loadfunc(file)
    if not loader then
      return "\n\t[lualoader] Loading error:\n\t"..err
    end
    return loader
  end
  package.searchers[pos] = loader
end

local binary_loader = function(file)
  local base = file:match("/([^%.]+)%.[%w]+$")
  local symbol = base:gsub("/","_")
  return package.loadlib(file, "luaopen_"..symbol)
end

-- Revert the package searchers to use .
--
-- Package searching logic is overridden by default in LuaTeX to use kpse.
-- Calling this function reverts the searchers to use package.path and
-- package.cpath.
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

return ufy
