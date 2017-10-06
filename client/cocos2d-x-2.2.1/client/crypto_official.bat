rd /s/q Resources_official
md Resources_official
xcopy Resources\* Resources_official /e/y
copy official\config.json Resources_official\config.json
call res_crypto.bat Resources_official Resources_official ..\pack_tools 1