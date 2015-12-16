#!/bin/bash

echo Build "$LUA"...

if [ "$LUA" == "LuaJIT" ]; then
  wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz -O LuaJIT-2.0.4.tar.gz
 tar xvf LuaJIT-2.0.4.tar.gz && cd LuaJIT-2.0.4
  make && make install
elif [ "$LUA" == "Lua 5.3" ]; then
  wget http://www.lua.org/ftp/lua-5.3.2.tar.gz -O lua-5.3.2.tar.gz
  tar xvf lua-5.3.2.tar.gz && cd lua-5.3.2
  make linux && make install
fi
cd ..

echo Build Luarocks
wget http://keplerproject.github.io/luarocks/releases/luarocks-2.2.3-rc2.tar.gz -o luarocks-2.2.3-rc2.tar.gz
tar xvf luarocks-2.2.3-rc2.tar.gz && cd luarocks-2.2.3-rc2
make && make install
cd ..
