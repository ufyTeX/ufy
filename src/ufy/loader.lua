local loader = {}

-- Cache the current kpse based searchers
local kpse_lua_searcher = package.searchers[2]
local kpse_clua_searcher = package.searchers[3]

-- Emulates the default package.searchers[2] searcher.
local function lua_searcher(name)
  local file, err = package.searchpath(name,package.path)
  if err then
    return err
  else
    return loadfile(f)
  end
end

-- Emulates the default package.searchers[3] searcher.
local function clua_searcher(name)
  local file, err = package.searchpath(name, package.cpath)
  if err then
    return err
  else
    local symbol = name:gsub("%.","_")
    return package.loadlib(f, "luaopen_"..symbol)
  end
end

local function combine_searchers(searcher1, searcher2, identifier)
  return function(name)
    print("Using "..identifier)
    print("Looking for "..name)
    -- First look under the default searcher
    local loader1, file1 = searcher1(name)
    print(loader1)
    if type(loader1) == "string" and not file1 then -- Not found using searcher1. Try searcher2
      print("Looking again for "..name)
      local loader2, file2 = searcher2(name)
      if not file2 then return string.format("\n\t%s\n\t[%s] %s\n\t",loader1, identifier,loader2) end
      return loader2, file2
    end
    return loader1, file1
  end
end

-- Revert the package searchers to use package.path and package.cpath
-- in case a module is not found.
--
-- Package searching logic is overridden by default in LuaTeX to use kpse.
-- Calling this function reverts the searchers to use package.path and
-- package.cpath, if the kpse based searcher is not able to locate
-- a module.
--
-- Package Loading References:
-- 1. http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
-- 2. LuaTeX Manual, Section 3.2, Lua behavior
function loader.revert_package_searchers()
  package.searchers[2] = combine_searchers(kpse_lua_searcher, lua_searcher, "lualoader")
  package.searchers[3] = combine_searchers(kpse_clua_searcher, clua_searcher, "lua C loader")
end

function loader.restore_kpse_searchers()
  package.searchers[2] = kpse_lua_searcher
  package.searchers[3] = kpse_clua_searcher
end

return loader
