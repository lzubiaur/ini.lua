--

local lpeg = require 'lpeg'
lpeg.locale(lpeg)   -- adds locale entries into 'lpeg' table

-- The module
local ini = {}

-- Config
local sc = '=' -- Separator character
local cc = ';#' -- Comment characters
local lowercase_keys = true -- TODO

local P = lpeg.P    -- Pattern
local R = lpeg.R    -- Range
local S = lpeg.S    -- String
local V = lpeg.V    -- Variable
local C = lpeg.C    -- Capture
local Cf = lpeg.Cf
local Cc = lpeg.Cc  -- Constant capture
local Ct = lpeg.Ct  -- Table capture
local Cg = lpeg.Cg  -- Group capture
local space = lpeg.space
local alpha = lpeg.alpha
local digit = lpeg.digit

ini.grammar = P{
    'all';
    -- key = C(_alpha^1 * (_alpha + digit)^0) / function(k) return k:lower() end * space^0, -- TODO
    _alpha = P('_') + alpha, -- underscore or alpha character
    key = C(V'_alpha'^1 * (V'_alpha' + digit)^0) * space^0,
    sep = P(sc)^-1 * space^0,
    cr = P'\n' + P'\r\n',
    comment = C(S(cc)^1) * C(lpeg.print^0),
    value = C(lpeg.print^1),
    set = V'key' * V'sep' * V'value',
    section = P'['^1 * space^0 * V'key' * space^0 * P']'^1 * space^0,
    line = space^0 * V'comment'^0 * V'section'^0 * V'set'^0,
    lines = Ct(V'line' * (V'cr' * V'line')^0),
    all = V'lines' * (V'cr' + -1), -- lines followed by a line return or end of string
}

ini.parse = function(data)
    if type(data) == 'string' then
        return lpeg.match(ini.grammar,data)
    end
    return {}
end

return ini
