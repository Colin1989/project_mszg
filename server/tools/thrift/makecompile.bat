thrift -gen erl rpc.thrift

del /q ..\..\src\thrift\*

copy  gen-erl\* ..\..\src\thrift\

rmdir /s/q gen-erl

pause