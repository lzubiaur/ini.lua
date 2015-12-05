local lpeg = require 'lpeg'

local P = lpeg.P -- Pattern
local R = lpeg.R -- Range
local S = lpeg.S -- String

print '-- test 1'
local patt = P "abc"
print(patt:match("abc"))    -- 4
print(patt:match("bc"))     -- nil
print(patt:match("abcabc")) -- 4

print '-- test 2'
patt = P(3) -- String with at least 3 char
-- patt = -P(3) -- String with less than 3 char
print(patt:match("abc"))    -- 4
print(patt:match("ab"))     -- nil
print(patt:match("abcabc")) -- 4

print '-- test 3'
patt = R('09')
print(patt:match('123456')) -- 2 Match the only the first char
print(patt:match('102d'))   -- 2
print(patt:match('d123'))   -- nil

print '-- test 4'
patt = R('az', 'AZ')
print(patt:match('ABC'))    -- 2
print(patt:match('ABC123')) -- 2
print(patt:match('12ABC'))  -- nil

print '-- test 5'
patt = R('09')^6            -- At least 6 digit
print(patt:match('123'))    -- nil
print(patt:match('123456')) -- 7
print(patt:match('A123'))   -- nil

print '-- test 6'
patt = -R('09')             -- No digit
print(patt:match('A'))    -- 1
print(patt:match('1A'))    -- nil
print(patt:match('A1'))   -- 1

print '-- test 7'
patt = S('/*-+')
print(patt:match('/'))      -- 2
print(patt:match('+'))      -- 2
print(patt:match('A'))      -- nil

print '-- test 8'
patt = -lpeg.P(1)
print(patt:match(''))
print(patt:match('abc'))

print '-- test 9'
patt = S('/*-+')^1  -- one or more occurence
print(patt:match('/-+*'))  -- 5
print(patt:match('*'))      -- 2
print(patt:match('A'))      -- nil

print '-- test 10'
patt = S('/*-+')^-2  -- at most 2 occurences
print(patt:match('/-+*'))  -- 3
print(patt:match('*'))     -- 2
print(patt:match('*+'))    -- 3

print '-- test 11'
patt = S('/*-+')^-2 * -1 -- at most 2 occurences and then the end of the string
print(patt:match('/-+*'))  -- nil
print(patt:match('*'))     -- 2
print(patt:match('*+'))    -- 3

-- locale
-- lnum, alpha, cntrl, digit, graph, lower, print, punct, space, upper, xdigit
lpeg.locale(lpeg)
local V = lpeg.V
local space = lpeg.space
local alpha = lpeg.alpha
local digit = lpeg.digit
local C = lpeg.C    -- Capture
local Cc = lpeg.Cc  -- Constant capture
local Ct = lpeg.Ct  -- Table capture
local Cg = lpeg.Cg  -- Group capture

print '-- test 12'
local _alpha = P('_') + alpha -- underscore or alpha character
local key = C(_alpha^1 * (_alpha + digit)^0) * space^0 -- Must start with at least one underscore or alpha followed by zero or more underscore, alpha or digit
local sep = P('=')^-1 * space^0
-- local value = C(alpha^1 * space^0)
local value = C(lpeg.print ^1)
local line = key * sep * value
local k, v = line:match('_sds5 = ,1hello world')
print('['..k..']', '['..v..']')

print '-- test 13'
local section = P'['^1 * space^0 * key * Cc'section' * space^0 * P']'^1 * space^0
print(section:match('[my_section_test1]'))
print(section:match('[ my_section_test ]  '))
print(section:match('[1my_section_test]'))

do
print '-- test 15'
local upper = P'a'^0
local lower = P'A'^0
local digit = P'9'^0
local test_add = C(upper + lower + digit)
local test_mult = C(upper * lower * digit)
print('-- ',test_add:match('AZa1'))
print('-- ',test_add:match('1aAZ'))
print('-- ',test_mult:match('AZa'))
end

local function print_table_r(t,i)
    if t == nil then
        print'nil'
    elseif type(t) == 'table' then
        print('{')
        for _,v in pairs(t) do
            print_table_r(v)
        end
        print('}')
    else
        io.write(t,': ',type(t),'\n')
    end
end

print '-- test 14'
local ini = require 'ini'
print_table_r(ini.parse('a_key = this is the value for this set'))
print_table_r(ini.parse('[this_is_a_section_test]'))
print_table_r(ini.parse('; this is a comment test'))
local t = ini.parse[[
; this is a comment

[opengl]
fullscreen = true

window = 200,200
]]
print_table_r(t)
