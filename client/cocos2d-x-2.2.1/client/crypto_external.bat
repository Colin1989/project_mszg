rd /s/q Resources_external
md Resources_external
xcopy Resources\* Resources_external /e/y
copy external\config.json Resources_external\config.json
call res_crypto.bat Resources_external Resources_external ..\pack_tools 1