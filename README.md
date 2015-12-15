# ini.lua
Simple [ini file format][3] parser for Lua.

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

Copy the ini.lua file somewhere to your project root or maybe in the ```lib``` folder.

ini.lua uses [LPeg][1] and depending on your needs it may be installed using [LuaRocks][5] or built from source into your project.

```
sudo luarocks install lpeg
```

You may also optionally install [busted][2] to run the spec.
```
sudo luarocks install busted
git clone https://github.com/lzubiaur/ini.lua
cd lua.ini
busted spec/parser.lua
```

## Usage

```lua
local ini = require 'ini'

-- Parse input string
local config = ini.parse [[
  [window]
  fullscreen=true
  size=200,200
]]

-- Or parse files
local config = ini.parse_file('my_config.ini')

if config.window.fullscreen then
  -- Run the app in fullscreen
end
```

## Configuration

ini.lua can be configured using the ```ini.config``` function. The following parameters are currently available:
* ```separator```: string to define the separator character. Default is the equal character (=)
* ```comment```: string to specify the comment characters. Default is semicolon (;) and number sign (#)
* ```trim```: By default leading and trailing white spaces are trimmed. This can be override by setting false to this parameter.
* ```lowercase```: By default the keys are not case sensitive. This can be changed by forcing the keys to be lowercase by setting this parameter to true.

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

The previous ini will result in a Lua table like below.

```
{
  window = {
    fullscreen = ' true'
    size = ' 200,200'
  }
}
```
Please not the leading spaces for both fullscreen and size values.

## License
This project is licensed under the terms of the [MIT license][4].

[1]:http://www.inf.puc-rio.br/~roberto/lpeg/
[2]:http://olivinelabs.com/busted/
[3]:https://en.wikipedia.org/wiki/INI_file
[4]:https://opensource.org/licenses/MIT
[5]:https://luarocks.org/
