local l = require("lpeg")
-- bring locales into lpeg
l.locale(l)

local function parse_feature(f)
  --print("parsing feature")
  --print(spt.block(f))
  local k = f.name
  local v

  -- set to true if turned on
  if f.onoff == "+" then v = true end

  -- set to value if set
  if f.val then v = f.val end

  -- override to false if explicitly turned off
  if f.onoff == "-" then v = false end

  -- print(string.format("returning %s = %s", k, v))
  return { [k] = v }
end

local function merge_tables(...)
  local args = {...}
  local t = {}
  for _,f in ipairs(args) do
    for k,v in pairs(f) do
      t[k] = v
    end
  end
  return t
end

local function merge_features(...)
  local t = merge_tables(...)
  return {features = t}
end

local function process_options(opts)
  local res = {}

  for i = 1,#opts do
    if type(opts[i]) == 'table' then
      if opts[i].name == 'S' then res.opticalsize = opts[i].val end
    else
      local o = string.upper(opts[i])
      if o == "BI" or i == "IB" then res.bolditalic = true
      elseif o == "I" then res.italic = true
      elseif o == "B" then res.bold = true
      elseif o == "OT" then res.opentype = true
      elseif o == "AAT" then res.aat = true
      elseif o == "GR" then res.graphite = true
      elseif o == "ICU" then res.icu = true
      end
    end
  end
  if next(res) == nil then return nil end
  return res
end

-- font spec string parser

local space = l.space^0

local filename = l.P"[" *
                 l.Cg((1 - l.S":]")^1, "filename") *
                 (l.P":" * l.Cg(l.digit^1, "fontindex"))^-1 *
                 l.P"]"
local alpha_opt = l.C(l.alpha^1)
local value_opt = l.Ct(l.Cg(l.alpha^1, "name") * l.P"=" * l.Cg(l.digit^1, "val"))
local option = l.P"/" * (value_opt + alpha_opt)
local options = l.Ct(option * (space * option)^0) / process_options

local fontname = l.Cg(l.Cmt((1 - l.P"[") * (1 - l.S":/") ^ 0, function(_,_,name)
  -- trim spaces
  return true, string.gsub(name, "^%s*(.-)%s*$", "%1")
end),"fontname") * l.Cg(options,"options")^-1

local identifier = l.Ct(filename + fontname)

local feature = l.Ct(
                  space *
                  l.Cg(l.S"+-"^-1, "onoff") *
                  l.Cg(l.alpha^1, "name") *
                  (l.P"=" * l.Cg((1-l.P",")^1, "val"))^-1
                ) / parse_feature

local features = (feature * (l.P","^1 * feature)^0) / merge_features

local font_spec = (identifier  * (l.P":" * features)^-1) * -1 / merge_tables

local fontspec = {}

function fontspec.parse(spec_str)
  return font_spec:match(spec_str)
end

return fontspec
