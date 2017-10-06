@echo off
echo "starting..."

del *flymake*
erl -noshell -make
cd ebin
erl -noshell -s gen_protocal start -s gen_enum_def start -s gen_protocal_lua start -s init stop

copy  protocal.erl ..\..\..\src
copy  packet_def.hrl ..\..\..\include
copy  enum_def.hrl ..\..\..\include
copy  NetEnumDef.lua ..\..\..\..\client\cocos2d-x-2.2.1\client\Resources\Script\Network\
copy  NetMsgType.lua ..\..\..\..\client\cocos2d-x-2.2.1\client\Resources\Script\Network\
copy  NetPacket.lua ..\..\..\..\client\cocos2d-x-2.2.1\client\Resources\Script\Network\


cd ..\

echo "finish"
pause