local loader = {}

-- Cache the current kpse based searchers
local kpse_lua_searcher = package.searchers[2]
local kpse_clua_searcher = package.searchers[3]

-- Emulates the default package.searchers[2] searcher.
local function lua_searcher(name)
  local file, err = package.searchpath(name,package.path)
  if err then
    return string.format("[lua searcher]: module not found: '%s'%s", name, err)
  else
    return loadfile(file)
  end
end

-- Emulates the default package.searchers[3] searcher.
local function clua_searcher(name)
  local file, err = package.searchpath(name, package.cpath)
  if err then
    return string.format("[lua C searcher]: module not found: '%s'%s", name,err)
  else
    local symbol = name:gsub("%.","_")
    return package.loadlib(file, "luaopen_"..symbol)
  end
end

local function combine_searchers(searcher1, searcher2)
  return function(name)
    local loader1 = searcher1(name)
    if type(loader1) == "string" then -- Not found using searcher1. Try searcher2.
      local loader2 = searcher2(name)
      if type(loader2) == "string" then -- Not found using searcher2. Return error.
        return string.format("%s\n\t%s", loader1, loader2)
      end
      return loader2
    end
    return loader1
  end
end

--- Use package.path and package.cpath to find Lua modules,
-- in case kpse searching fails.
--
-- Package searching logic is overridden by default in LuaTeX to use kpse.
-- Calling this function reverts the searchers to use package.path and
-- package.cpath, if the kpse based searcher is not able to locate
-- a module.
--
-- Package Loading References:
-- 1. http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
-- 2. LuaTeX Manual, Section 3.2, Lua behavior
function loader.add_lua_searchers()
  package.searchers[2] = combine_searchers(kpse_lua_searcher, lua_searcher)
  package.searchers[3] = combine_searchers(kpse_clua_searcher, clua_searcher)
end


--- Restore the kpse package searchers that are used by default in LuaTeX,
--  and revert the lua package searchers.
--
-- Call this to restore the default LuaTeX behavior for searching packages,
-- if you had earlier overridden it using `ufy.loader.add_lua_searchers()`.
function loader.revert_lua_searchers()
  package.searchers[2] = kpse_lua_searcher
  package.searchers[3] = kpse_clua_searcher
end

return loader
