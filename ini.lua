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

-- See README.md for the documentation and examples

local lpeg = require 'lpeg'
lpeg.locale(lpeg)   -- adds locale entries into 'lpeg' table

-- The module
local ini = {}

ini.config = function(t)
  -- Config parameters
  local sc = t.separator or '=' -- Separator character
  local cc = t.comment or ';#' -- Comment characters
  local trim = t.trim == nil and true or t.trim -- Should capture or trim white spaces
  local lc = t.lowercase == nil and false or t.lowercase -- Should keys be lowercase?
  local escape = t.escape == nil and true or t.escape -- Should string literals used escape sequences?

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
  local space = lpeg.space -- include tab and new line (\n)
  local alpha = lpeg.alpha
  local digit = lpeg.digit
  local any = P(1)

  local _alpha = P('_') + alpha -- underscore or alpha character
  local keyid = _alpha^1 * (_alpha + digit)^0
  -- Lua escape sequences (http://www.lua.org/pil/2.4.html)
  if escape then
    any = any
      - P'\\a' + P'\\a'/'\a' -- bell
      - P'\\n' + P'\\n'/'\n' -- newline
      - P'\\r' + P'\\r'/'\r' -- carriage return
      - P'\\t' + P'\\t'/'\t' -- horizontal tab
      - P'\\f' + P'\\f'/'\f' -- form feed
      - P'\\b' + P'\\b'/'\b' -- back space
      - P'\\v' + P'\\v'/'\v' -- vertical tab
      - P'\\\\' + P'\\\\'/'\\' -- backslash
  end

  ini.grammar = P{
    'all';
    key = not lc and C(keyid) * space^0 or Cs(keyid / function(s) return s:lower() end) * space^0,
    sep = P(sc),
    cr = P'\n' + P'\r\n',
    comment = S(cc)^1 * lpeg.print^0,
    string = space^0 * P'"' * Cs((any - P'"' + P'""'/'"')^0) * P'"' * space^0,
    value = trim and space^0 * C(((space - '\n')^0 * (any - space)^1)^1) * space^0 or C((any - P'\n') ^1),
    set = Cg(V'key' * V'sep' * (V'string' + V'value')),
    line = space^0 * (V'comment' + V'set'),
    body = Cf(Ct'' * (V'cr' + V'line')^0, rawset),
    label = P'[' * space^0 * V'key' * space^0 * P']' * space^0, -- the section label
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
