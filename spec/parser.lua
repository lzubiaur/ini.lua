describe('Test the parser', function()
    local ini = require 'ini'

    it('basic test', function()
        assert.same({'a_key', 'this is the value for this set'}, ini.parse('a_key = this is the value for this set'))
        assert.same({'this_is_a_section_test'}, ini.parse('[this_is_a_section_test]'))
        assert.same({';',' this is a comment test'},ini.parse('; this is a comment test'))
    end)

    it('section', function()
        assert.same({'section_test'}, ini.parse('[section_test]'))
        assert.same({'section_test1'}, ini.parse('[section_test1]')) -- test digit
        assert.same({'s1ection_test'}, ini.parse('[s1ection_test]')) -- test digit
        -- assert.same(ini.parse('[ section_test ]  '), {'section_test'}) -- test space
        -- assert.is_nil(ini.parse('[test_section'))
        -- -- assert.is_nil(ini.parse('test_section]'))
        -- assert.is_nil(ini.parse('[1my_section_test]')) -- fail because starts with a digit
    end)

    it('Multi-lines string',function()
        local t = ini.parse[[
        ; this is a comment

        [opengl]
        fullscreen = true

        window = 200,200
        ]]
        assert.same(t,{
            ';',
            ' this is a comment',
            'opengl',
            'fullscreen',
            'true',
            'window',
            '200,200'
        })
    end)

end)
