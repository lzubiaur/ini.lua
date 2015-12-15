# ini.lua
Simple [ini file format][3] parser/reader for Lua using [LPeg][1].

## Example

```ini
project=My Awesome app
version=1.2.0
[window]
fullscreen=true
size=200,200
```

The previous ini file is converted into the following Lua table.

```lua
{
  project = 'My Awesome app',
  version = '1.2.0',
  window = {
    fullscreen = 'true',
    size = '200,200'
  }
}
```

## Installation

Add the ini.lua file somewhere to your project root or maybe in the `lib` folder.

ini.lua uses [LPeg][1] and depending on your needs it should be installed using [LuaRocks][5] or built from source into your project.

```
sudo luarocks install lpeg
```

You may also optionally install [busted][2] to run the spec.

```
git clone https://github.com/lzubiaur/ini.lua
cd lua.ini
sudo luarocks install busted
busted spec/parser.lua
```

## Usage

Load the ini module using `require 'ini'` or `require 'lib.ini'` if you copied the ini.lua file in the `lib` folder.

Call either `ini.parse` or `ini.parse_file` to parse a single string or a file. Multiline string can be passed to `ini.parse` using the double square brackets syntax.

The parse functions return a table that you can use to access the ini keys/properties. For instance to get the value of the key `fullscreen` from the `window` section you simply use `t.window.fullscreen` or `t['window']['fullscreen']`.

```lua
local ini = require 'ini' -- or require 'lib.ini'

-- Parse input string
local settings = ini.parse [[
  [window]
  fullscreen=true
  size=200,200
]]

-- Or parse an file input
local settings = ini.parse_file('my_config.ini')

if settings.window.fullscreen then
  -- Run the app in fullscreen
end
```
## Format

#### Keys and sections
TODO
* Duplicate keys and sections name.
* Global or "default" properties.

#### Comments
TODO

#### White spaces
TODO

* Trimming
* Double quoted string
* Blank lines

## Configuration

ini.lua can be configured using the `ini.config` function. The following parameters are currently available:
* `separator`: string to define the separator character. Default is the equal character (=)
* `comment`: string to specify the comment characters. Default is semicolon (;) and number sign (#)
* `trim`: By default leading and trailing white spaces are trimmed. This can be override by setting false to this parameter.
* `lowercase`: By default the keys are not case sensitive. This can be changed by forcing the keys to be lowercase by setting this parameter to true.

```lua
local ini = require 'ini'

ini.config {
  separator = ':',
  comment = '^',
  trim = false,
  lowercase = true
}

local config = ini.parse [[
  ^ Window parameters
  [WINDOW]
  FULLSCREEN : true
  Size : 200,200
]]
```

The previous example will produce the Lua table below. Please note that the leading spaces for both fullscreen and size values are now captured.

```
{
  window = {
    fullscreen = ' true'
    size = ' 200,200'
  }
}
```

## License
This project is licensed under the terms of the [MIT license][4].

[1]:http://www.inf.puc-rio.br/~roberto/lpeg/
[2]:http://olivinelabs.com/busted/
[3]:https://en.wikipedia.org/wiki/INI_file
[4]:https://opensource.org/licenses/MIT
[5]:https://luarocks.org/
