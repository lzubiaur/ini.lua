-- Copyright (c) 2015 Laurent Zubiaur

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local lpeg = require 'lpeg'
lpeg.locale(lpeg)   -- adds locale entries into 'lpeg' table

-- The module
local ini = {}

-- TODO failed if there is an empty line at eof
-- NOTE
-- keys and sections redundancy
-- Redundant keys within the same section will be ignored and only the last occurence will be captured.
-- Sections with the same labels will be ignored and the last reduntant section occurence will be captured.

ini.config = function(t)
  -- Config parameters
  local sc = t.separator or '=' -- Separator character
  local cc = t.comment or ';#' -- Comment characters
  local lowercase_keys = true -- TODO

  -- LPeg shortcut
  local P = lpeg.P    -- Pattern
  local R = lpeg.R    -- Range
  local S = lpeg.S    -- String
  local V = lpeg.V    -- Variable
  local C = lpeg.C    -- Capture
  local Cf = lpeg.Cf  -- Capture floding
  local Cc = lpeg.Cc  -- Constant capture
  local Ct = lpeg.Ct  -- Table capture
  local Cg = lpeg.Cg  -- Group capture
  local Cs = lpeg.Cs  -- Capture String (replace)
  local space = lpeg.space
  local alpha = lpeg.alpha
  local digit = lpeg.digit
  local any = P(1)
  
  ini.grammar = P{
    'all';
    -- key = C(_alpha^1 * (_alpha + digit)^0) / function(k) return k:lower() end * space^0, -- TODO
    _alpha = P('_') + alpha, -- underscore or alpha character
    key = C(V'_alpha'^1 * (V'_alpha' + digit)^0) * space^0,
    sep = P(sc),
    cr = P'\n' + P'\r\n',
    comment = S(cc)^1 * lpeg.print^0,
    string = space^0 * P'"' * Cs((any - P'"' + P'""'/'"')^0) * P'"' * space^0,
    value = space^0 * C(((space - '\n')^0 * (any - space)^1)^1) * space^0,
    set = Cg(V'key' * V'sep' * (V'string' + V'value')),
    line = space^0 * (V'comment' + V'set'),
    body = Cf(Ct'' * (V'cr' + V'line')^0, rawset),
    label = P'['^1 * space^0 * V'key' * space^0 * P']'^1 * space^0, -- the section label
    section = space^0 * Cg(V'label' * V'body'),
    sections = V'section' * (V'cr' + V'section')^0,
    all = Cf(Ct'' * ((V'cr' + V'line')^0 * V'sections'^0), rawset) * (V'cr' + -1), -- lines followed by a line return or end of string
  }
end

ini.parse = function(data)
  if type(data) == 'string' then
    return lpeg.match(ini.grammar, data)
  end
  return {}
end

ini.parse_file = function(filename)
  local f = assert(io.open(filename, "r"))
  local t = ini.parse(f:read('*all'))
  f:close()
  return t
end

-- Use default settings
ini.config{}

return ini
