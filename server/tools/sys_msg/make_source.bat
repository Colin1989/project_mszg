rm -f *flymake*
erl -make
erl -noshell -s make_sys_msg_def start -s init stop
copy  sys_msg.lua ..\..\..\client\cocos2d-x-2.2.1\client\Resources\Script\Network\
pause