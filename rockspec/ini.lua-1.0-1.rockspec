package = "ini.lua"
version = "1.0-1"

source = {
   url = "https://github.com/lzubiaur/ini.lua",
}

dependencies = {
   "lpeg",
}

description = {
   summary = "A simple INI parser in Lua",
   homepage = "https://github.com/lzubiaur/ini.lua",
   license = "MIT"
}

build = {
   type = "builtin",
   modules = {
      ["ini.lua"] = "ini.lua"
   }
}