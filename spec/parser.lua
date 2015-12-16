describe('Test the parser', function()
  local ini = require 'ini'

  before_each(function()
    -- Default settings
    ini.config{}
  end)

  it('#basic test', function()
    assert.same({ name = 'value' }, ini.parse('name = value'))
    assert.same({ name = '= value' }, ini.parse('name == value'))
    assert.same({ name = ': value' }, ini.parse('name =: value'))
    assert.same({ section_test = {} }, ini.parse('[section_test]'))
    assert.same({}, ini.parse('; this is a comment test'))
  end)

  it('#trim whitespaces test', function()
    assert.same({ name = 'value' }, ini.parse('name = value '))
    assert.same({ name = 'value' }, ini.parse(' name = value '))
    assert.same({ name = 'value' }, ini.parse('name =   value  '))
    assert.same({ name = 'value test' }, ini.parse('name = value test '))
    assert.same({ name = 'value test', name2 = 'value test' }, ini.parse([[
name = value test
name2 = value test
]]))
  end)

  it('#notrim test', function()
    ini.config {
      trim = false
    }
    assert.same({ name = ' value ' }, ini.parse('name = value '))
    assert.same({ name = '  value  ' }, ini.parse('name =  value  '))
    assert.same({ name = ' value test ' }, ini.parse('name = value test '))
    assert.same({ name = 'value test' }, ini.parse('name =value test'))
    assert.same({ name = ' value test', name2 = 'value test' }, ini.parse([[
name = value test
name2 =value test
]]))
  end)

  it('#comment test', function()
    assert.same({}, ini.parse('; comment'))
    assert.same({}, ini.parse(' ; comment'))
    assert.same({name = 'value ; comment'}, ini.parse('name = value ; comment'))
    assert.same({}, ini.parse('# comment'))
    assert.same({}, ini.parse[[
; comment
# comment
]])
  end)

  it('#lowercase test', function()
    ini.config {
      lowercase = true
    }
    assert.same({ name = 'value' }, ini.parse('NAME = value'))
    assert.same({ _name = 'value' }, ini.parse('_Name = value'))
    assert.same({
      window = {
        size = '200,200'
      }
    }, ini.parse[[
[ WINDOW ]
Size = 200,200
]])
  end)

  it('#string test', function()
    assert.same({ name = '  value ' }, ini.parse('name = "  value "')) -- add explicit whitespaces to string
    assert.same({ name = ' "value' }, ini.parse('name =" ""value"')) -- Escaping double quotes
    assert.same({ name = 'value' }, ini.parse('name = "value" ')) -- Whitespace before and after double quotes are trimmed
    assert.same({ name = ' "value' }, ini.parse('name = " ""value" '))
  end)

  it('custom #settings', function()
    ini.config {
      separator = ':',
      comment = '%!'
    }
    assert.same({ name = 'value' }, ini.parse('name : value'))
    assert.same({ name = ': value' }, ini.parse('name :: value'))
    assert.is_nil(ini.parse('name = value')) -- Must fail
    assert.same({}, ini.parse('! this is a comment test'))
    assert.same({}, ini.parse('% this is a comment test'))
  end)

  it('#section label', function()
    assert.same({ section_test = {} }, ini.parse('[section_test]'))
    assert.same({ section_test1 = {} }, ini.parse('[section_test1]')) -- test digit
    assert.same({ s1ection_test = {} }, ini.parse('[s1ection_test]')) -- test digit
    assert.same({ section_test = {} }, ini.parse('[ section_test ]  ')) -- test space

    assert.same({ section_test = {} }, ini.parse('[ section_test ] # comment')) -- For some reason this works ?!
    -- assert.same({ section_test = {} }, ini.parse('[ section_test ] name = value\nname2 = value')) -- this works too
    -- Fail tests
    assert.is_nil(ini.parse('[[ section_test ]'))
    assert.is_nil(ini.parse('[ section_test ]]'))
    assert.is_nil(ini.parse('[[ section_test ]]'))
    assert.is_nil(ini.parse('[test_section'))
    assert.is_nil(ini.parse('test_section]'))
    assert.is_nil(ini.parse('[ section test ]'))
    assert.is_nil(ini.parse('[ section test ] trash'))
    assert.is_nil(ini.parse('[1my_section_test]')) -- fail because starts with a digit
  end)

  it('Multi-lines no section', function()
    assert.same({
      project = 'My Game',
      version = '1.0.0'
    }, ini.parse[[
; Default
project = My Game
version = 1.0.0
]])
  end)

  it('Test default and one section', function()
    assert.same({
      project = 'My Game',
      version = '1.0.0',
      window = {
        fullscreen = 'true',
        size = '200,200'
      }
    }, ini.parse[[
; Default
project = My Game
version = 1.0.0
[window]
fullscreen = true
size = 200,200
]])
  end)

  it('Test no default', function()
    assert.same({
      window = {
        fullscreen = 'true',
        size = '200,200'
      }
    }, ini.parse[[
[window]
fullscreen = true
size = 200,200
]])
  end)

  it('Test multiple sections', function()
    assert.same({
      window = {
        fullscreen = 'true',
        size = '200,200',
      },
      app = {
        name = 'My Game',
        version = '1.0.0'
      }
    }, ini.parse[[
[window]
; comment with space
fullscreen = true
size = 200,200
[app]
name = My Game
version = 1.0.0
]])
  end)

  it('Test empty lines and spaces', function()
    assert.same({
      window = {
        fullscreen = 'true',
        size = '200,200'
      }
    }, ini.parse[[

  [window]

 fullscreen = true
 size = 200,200

]])
  end)

  it('test #duplicate', function()
    assert.same({
      window = {
        fullscreen = 'false',
        version = '2.0'
      }
    }, ini.parse[[
[window]
fullscreen = true
size = 200

[window]
version = 1.0
fullscreen = false
version = 2.0
]])
  end)

  it('test file input', function()
    assert.same({
      window = {
        fullscreen = 'true',
        size = '200,200',
      },
      app = {
        name = 'My Game',
        version = '1.0.0'
      }
    }, ini.parse_file('spec/test.ini'))
    -- assert.same({},ini.parse_file('spec/invalid.ini'))
    assert.has_error(function() ini.parse_file('spec/does_not_exist.ini') end)
    end)

end)

describe('Pattern tests', function()
  local lpeg = require 'lpeg'

  local P = lpeg.P
  local C = lpeg.C
  local Ct = lpeg.Ct

  local space = lpeg.space
  local digit = lpeg.digit
  local alpha = lpeg.alpha

  local _alpha = P('_') + alpha -- match one alpha or underscore character

  it('alpha', function()
    assert.equals(_alpha:match('a'), 2)
    assert.equals(_alpha:match('A'), 2)
    assert.equals(_alpha:match('abc'), 2)
    assert.equals(_alpha:match('_'), 2)
    -- Must fail
    assert.is_nil(_alpha:match(' '))
    assert.is_nil(_alpha:match('1'))
  end)

  local key = C(_alpha^1 * (_alpha + digit)^0) * space^0

  it('key', function()
    assert.equals('_', key:match('_'))
    assert.equals('a', key:match('a'))
    assert.equals('_aA', key:match('_aA'))
    assert.equals('_Aa', key:match('_Aa'))
    assert.equals('_1', key:match('_1'))
    assert.equals('mykey', key:match('mykey'))
    assert.equals('my_key', key:match('my_key'))
    assert.equals('_my_key', key:match('_my_key'))
    assert.equals('mykey_', key:match('mykey_'))
    assert.equals('my_key_1', key:match('my_key_1'))
    assert.equals('mykey1', key:match('mykey1'))
    assert.equals('m1ykey', key:match('m1ykey'))
    assert.equals('_1mykey', key:match('_1mykey'))
    assert.equals('my_key', key:match('my_key ')) -- trailing space
    assert.equals('my', key:match('my key ')) -- TODO should succeed?
    -- Must fail
    assert.is_nil(key:match(''))
    assert.is_nil(key:match(' '))
    assert.is_nil(key:match('1'))
    assert.is_nil(key:match('[my_key]'))
  end)

  -- it('set', function()
  --     local s = spy.new(function(s) return key:match(s) end)
  --     s('name = value')
  --     print(key:match('name = value'))
  --     assert.spy(s).returned_with('name')
  -- end)

  local section = P'['^1 * space^0 * key * space^0 * P']'^1 * space^0

  it('section', function()
    assert.equals(section:match('[section_test]'), 'section_test')
    assert.equals(section:match('[_section_test]'), '_section_test')
    assert.equals(section:match('[ _section_test  ] '), '_section_test')
    assert.equals(section:match('[_1section_test]'), '_1section_test')
    assert.equals(section:match('[section_test1]'), 'section_test1')
    assert.equals(section:match('[section1_test]'), 'section1_test')
  end)

  -- local trim = Ct((space^0 * C(((space - '\n')^0 * (P(1) - space)^1)^1) * space^0 * P'\n'^0)^0)
  local trim = Ct((space^0 * C((P' '^0 * (P(1) - space)^1)^1) * space^0)^0)

  it('#trim_test', function()
    assert.same({'a'},trim:match(' a '))
    assert.same({'a a'}, trim:match(' a a '))
    assert.same({'a a','b'}, trim:match([[
 a a
b
]]))
  end)

end)
