local loader = {}

-- Copied from: http://tex.stackexchange.com/questions/218855/using-lualatex-and-sqlite3/219228#219228
local function make_loader(ppath, pos, loadfunc)
  local default_loader = package.searchers[pos]
  local ldr = function(name)
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
    local ldr,err = loadfunc(file,name)
    if not ldr then
      return "\n\t[lualoader] Loading error:\n\t"..err
    end
    return ldr
  end
  package.searchers[pos] = ldr
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
function loader.revert_package_searchers()
  make_loader(package.path,2,function(file)
    return loadfile(file)
  end)
  make_loader(package.cpath,3, binary_loader)
end

return loader
