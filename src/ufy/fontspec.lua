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

local function trim_spaces(t)
  for k,v in pairs(t) do
    t[k] = string.gsub(v, "^%s*(.-)%s*$", "%1")
  end
  return t
end

local function process_options(t)
  if t.option == "BI" or t.option == "IB" then return {bolditalic = true} end
  if t.option == "B" then return {bold = true} end
  if t.option == "I" then return {italic = true} end

end

-- font spec string parser

local filename = l.P"[" *
                 l.Cg((1 - l.S":]")^1, "filename") *
                 (l.P":" * l.Cg(l.digit^1, "fontindex"))^-1 *
                 l.P"]"

local fontname = l.Cg(l.Cmt((1 - l.P"[") * (1 - l.S":/") ^ 0, function(_,_,name)
  -- trim spaces
  return true, string.gsub(name, "^%s*(.-)%s*$", "%1")
end),"fontname")

local identifier = l.Ct(filename + fontname) 

local feature = l.Ct(
                  l.space^0 *
                  l.Cg(l.S"+-"^-1, "onoff") *
                  l.Cg(l.alpha^1, "name") *
                  (l.P"=" * l.Cg((1-l.P",")^1, "val"))^-1
                ) / parse_feature

local features = (feature * (l.P","^1 * feature)^0) / merge_features

local options = l.Ct(l.P"/" * l.Cg(l.P"BI" + l.P"B" + l.P"IB" + l.P"I", "option") * l.space^0) / process_options

local font_spec = (identifier * options^-1 * (l.P":" * features)^-1) * -1 / merge_tables

local fontspec = {}

function fontspec.parse(spec_str)
  return font_spec:match(spec_str)
end

return fontspec
