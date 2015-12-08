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

Copy the ini.lua to your project root or maybe in a ```lib``` folder.

ini.lua uses [LPeg][1] and depending on your needs you may install LPeg using [LuaRocks][5] or build LPeg from source and ship it with your app.

```
sudo luarocks install lpeg
```

You may also optionally install [busted][2] to run the spec.
```
sudo luarocks install busted
```

## Usage

```lua
local ini = require 'ini'

local config = ini.parse [[
  [window]
  fullscreen=true
  size=200,200
]]

if config.window.fullscreen then
  -- Run the app in fullscreen
end
```

## TODO

## License
This project is licensed under the terms of the [MIT license].

[1]:http://www.inf.puc-rio.br/~roberto/lpeg/
[2]:http://olivinelabs.com/busted/
[3]:https://en.wikipedia.org/wiki/INI_file
[4]:https://opensource.org/licenses/MIT
[5]:https://luarocks.org/
