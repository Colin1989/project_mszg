#!/bin/sh
cd /home/wow/server/
rm -rf deps/
svn up
chmod +x -R deps
cd deps/boss_db
./rebar clean
make
cd /home/wow/
chmod +x -R server
cd /home/wow/server/
make $1
./rebar generate