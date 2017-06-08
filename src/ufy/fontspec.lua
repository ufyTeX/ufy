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

-- font spec string parser

local filename = l.P"[" *
                 l.Cg((1 - l.S":]")^1, "filename") *
                 (l.P":" * l.Cg(l.digit^1, "fontindex"))^-1 *
                 l.P"]"

local fontname = l.Cg((1 - l.P"[") * (1 - l.P":") ^ 0, "fontname")

local identifier = l.Ct(filename + fontname)

local feature = l.Ct(
                  l.space^0 *
                  l.Cg(l.S"+-"^-1, "onoff") *
                  l.Cg(l.alpha^1, "name") *
                  (l.P"=" * l.Cg((1-l.P",")^1, "val"))^-1
                ) / parse_feature

local features = (feature * (l.P","^1 * feature)^0) / merge_features

local font_spec = (identifier * (l.P":" * features)^-1) / merge_tables

local fontspec = {}

function fontspec.parse(spec_str)
  return font_spec:match(spec_str)
end

return fontspec