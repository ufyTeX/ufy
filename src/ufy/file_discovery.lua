local path = require("path")

local file_discovery = {}

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
  return path.join(ufy.config_dir(), name)
end

local function find_map_file(name)
  -- print("find_map_file: "..name)
  return path.join(ufy.config_dir(), name)
end

local function find_font_file(name)
  -- print("find_font_file: "..name)
  if path.isfile(name) then
    return name
  else
    return nil
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
function file_discovery.add_callbacks()
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

return file_discovery
