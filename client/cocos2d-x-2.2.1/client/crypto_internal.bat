rd /s/q Resources_internal
md Resources_internal
xcopy Resources\* Resources_internal /e/y
copy internal\config.json Resources_internal\config.json
call res_crypto.bat Resources_internal Resources_internal ..\pack_tools 1