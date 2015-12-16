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

Clone this repo and add the ini.lua file somewhere to your project root or maybe in the `lib` folder.

```
git clone https://github.com/lzubiaur/ini.lua && cd lua.ini
```

ini.lua uses [LPeg][1] and depending on your needs it should be installed using [LuaRocks][5] or built from source into your project.

```
sudo luarocks install lpeg
```

You may also optionally install [busted][2] to run the spec.

```
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
Duplicate keys and sections are ignored and only the last occurrence will be captured.

```lua
t = ini.parse [[
  [window]
  fullscreen = true
  size = 200

  [window]
  fullscreen = false
]]

print(t.window.fullscreen) -- false
print(t.window.size) -- nil
```

Global or "default" properties can be defined at the beginning of the ini file. Those properties will be added to the root table.

```lua
t = ini.parse [[
  version = 1.0
  [window]
  fullscreen = true
]]

print(t.version) -- 1.0
```

#### Comments
Comments starts with the semicolon (;) or number character (#) and are only allowed on their own lines. Comments characters can be changed using the `ini.config` function (see configuration below). Blank lines and comments are ignored.

```ini
; comment
# another comment
```

#### White spaces and escape sequences
By default leading and trailing white spaces are ignored for section label and for both key name and value.
If you want to capture spaces you can either turn off trimming (see the configuration section) or use string literals (value enclosed in double quotes (")).

When using string literals, double quotes are escaped using two consecutive double quotes ("").

```ini
name = " string with spaces and ""double quotes"" "
```

```Lua
{
  name = ' string with spaces and "double quotes" '
}
```

When trimming is disabled *all* characters after the separator character are captured. Therefore `fullscreen = true` is converted into `fullscreen = ' true'`.

## Configuration

ini.lua can be configured using the `ini.config` function. The following parameters are currently available:
* `separator`: String to define the separator character. Default is the equal character (=).
* `comment`: String to specify the comment characters. Default is semicolon (;) and number sign (#).
* `trim`: By default leading and trailing white spaces are trimmed. This can be overridden by setting `false` to this parameter.
* `lowercase`: By default the keys are not case sensitive. This can be changed by forcing the keys to be lowercase by setting this parameter to true.
* `escape`: By default C-like escape sequences are interpreted. If set to false then escape sequences are left unchanged.

```lua
local ini = require 'ini'

ini.config {
  separator = ':',
  comment = '^',
  trim = false,
  lowercase = true,
  escape = false
}

local config = ini.parse [[
  ^ Window parameters
  [WINDOW]
  FULLSCREEN : true
  Size : 200,200
  newline : "\n"
]]
```

The previous example will produce the Lua table below. Please note that the leading spaces for both fullscreen and size values are now captured (`trim` parameter is set to `false`).

```
{
  window = {
    fullscreen = ' true',
    size = ' 200,200',
    newline = '\n'
  }
}
```

# TODO

* Parse comma separated values into array (e.g. `size=200,200` would become `size = {200,200}`)

## License
This project is licensed under the terms of the [MIT license][4].

[1]:http://www.inf.puc-rio.br/~roberto/lpeg/
[2]:http://olivinelabs.com/busted/
[3]:https://en.wikipedia.org/wiki/INI_file
[4]:https://opensource.org/licenses/MIT
[5]:https://luarocks.org/
