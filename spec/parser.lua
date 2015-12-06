describe('Test the ini parser', function()
    local ini = require 'ini'
    setup(function()
    end)

    it('basic test', function()
        assert.same(ini.parse('a_key = this is the value for this set'), {'a_key', 'this is the value for this set'})
        assert.same(ini.parse('[this_is_a_section_test]'), {'this_is_a_section_test'})
        assert.same(ini.parse('; this is a comment test'), {';',' this is a comment test'})
    end)

    it('section', function()
        assert.same(ini.parse('[section_test]'),{'section_test'})
        assert.same(ini.parse('[section_test1]'),{'section_test1'}) -- test digit
        assert.same(ini.parse('[section1_test]'),{'section1_test'}) -- test digit
        assert.same(ini.parse('[ section_test ]  '), {'section_test'}) -- test space
        assert.is_nil(ini.parse('[test_section'))
        -- assert.is_nil(ini.parse('test_section]'))
        assert.is_nil(ini.parse('[1my_section_test]')) -- fail because starts with a digit
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
