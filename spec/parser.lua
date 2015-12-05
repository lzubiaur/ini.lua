describe('Test the ini parser', function()
    local ini = require 'ini'
    setup(function()
    end)

    it('basic test', function()
        assert.are.same(ini.parse('a_key = this is the value for this set'), {'a_key', 'this is the value for this set'})
        assert.are.same(ini.parse('[this_is_a_section_test]'), {'this_is_a_section_test'})
        assert.are.same(ini.parse('; this is a comment test'), {';',' this is a comment test'})
    end)

    it('Multi-lines string',function()
        local t = ini.parse[[
        ; this is a comment

        [opengl]
        fullscreen = true

        window = 200,200
        ]]
        assert.are.same(t,{
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
