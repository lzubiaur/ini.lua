[![Build Status](https://travis-ci.org/lzubiaur/ini.lua.svg)](https://travis-ci.org/lzubiaur/ini.lua)

# INI.lua
Simple [INI file format][3] parser/reader for Lua using [LPeg][1].

## Example

```ini
project=My Awesome app
version=1.2.0
[window]
fullscreen=true
size=200,200
```

The previous INI file is converted into the following Lua table.

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

### Option 1: Install via LuaRocks (Recommended)

Once the LuaRocks package is available, you can easily install the parser using:

```bash
luarocks install ini.lua
```

### Option 2: Build from Source

Clone this repo and add the `ini.lua` file somewhere to your project root or maybe in the `lib` folder.

```
git clone https://github.com/lzubiaur/ini.lua && cd lua.ini
```

INI.lua uses [LPeg][1], and depending on your requirements, the LPeg module should be installed either via LuaRocks or built from source and bundled with your project.

```
sudo luarocks install lpeg
```

You can also optionally install [busted][2] to run the tests.

```
sudo luarocks install busted
busted
```

## Contribute

If you'd like to contribute, a development container (devcontainer) for Visual Studio Code is provided. Please include unit tests for your changes in `parser_spec.lua` where applicable. 

## Usage

To load the INI module, use:
```lua
require 'ini'  -- If INI.lua is in the default location
```
or
```lua
require 'lib.ini'  -- If you placed INI.lua inside the 'lib' folder
```

You can parse an INI string or file using either ini.parse or ini.parse_file:

* ini.parse: Parses a multiline string (use double square brackets for multiline strings).
* ini.parse_file: Parses an INI file from disk.

Both functions return a table, allowing you to access the INI keys and values. For example, to retrieve the value of the `fullscreen` key from the `window` section, you can use either `settings.window.fullscreen` or `settings['window']['fullscreen']`.

Example usage:

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

## Format

#### Keys and sections
Duplicate keys and sections are ignored, and only the last occurrence is retained.

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

Global or 'default' properties can be defined at the beginning of the INI file and will be added to the root table.

```lua
t = ini.parse [[
  version = 1.0
  [window]
  fullscreen = true
]]

print(t.version) -- 1.0
```

#### Comments
Comments begin with a semicolon (;) or hash (#) and must appear on their own lines. The comment characters can be customized using the `ini.config` function (see configuration below). Blank lines and comments are ignored.

```ini
; comment
# another comment
```

#### White spaces and escape sequences
By default, leading and trailing whitespace is ignored for section labels, key names, and values. To capture spaces, you can either disable trimming (see the configuration section) or use string literals (values enclosed in double quotes).

When using string literals, double quotes within the value are escaped with two consecutive double quotes ("").

```ini
name = " string with spaces and ""double quotes"" "
```

```Lua
{
  name = ' string with spaces and "double quotes" '
}
```

When trimming is disabled, all characters after the separator are captured. For example, `fullscreen = true` would be converted to `fullscreen = ' true'`.

## Configuration

INI.lua can be configured using the `ini.config` function. The following parameters are available:

* `separator`: Specifies the separator character. The default is the equal sign (=).
* `comment`: Defines the comment characters. The default is the semicolon (;) and number sign (#).
* `trim`: By default, leading and trailing whitespace is trimmed. Set this parameter to false to disable trimming.
* `lowercase`: By default, keys are case-insensitive. Set this parameter to true to force keys to be lowercase.
* `escape`: By default, C-like escape sequences are interpreted. Set this to false to prevent escape sequences from being processed.

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

The previous example will produce the following Lua table. Note that the leading spaces for both the fullscreen and size values are now captured, as the `trim` parameter is set to `false`.

```lua
{
  window = {
    fullscreen = ' true',
    size = ' 200,200',
    newline = '\n'
  }
}
```

## TODO

* Parse comma separated values into array (e.g. `size=200,200` would become `size = {200,200}`)

## License
This project is licensed under the terms of the [MIT license][4].

[1]:http://www.inf.puc-rio.br/~roberto/lpeg/
[2]:http://olivinelabs.com/busted/
[3]:https://en.wikipedia.org/wiki/INI_file
[4]:https://opensource.org/licenses/MIT
[5]:https://luarocks.org/
